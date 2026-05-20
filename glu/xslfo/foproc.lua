-- foproc.lua — proof-of-concept XSL-FO → HTML transformer.
--
-- Run as:  glu foproc.lua <input.fo>             → <input>.pdf
--          glu foproc.lua <input.fo> keep-html   → <input>.pdf and <input>.html
--                                                  (writes the intermediate
--                                                   HTML out for inspection /
--                                                   debugging)
--          glu foproc.lua <input.fo> out=NAME    → writes NAME instead of <input>.pdf
-- Note: keep-html and out=… are positional keywords, not `--flags`,
-- because glu reserves `--html` for its own debug output flag and
-- swallows it before the script sees it.
--
-- Coverage:
--   fo:simple-page-master       → @page { size, margin }
--   fo:flow                     → <body>
--   fo:block                    → <p style="..." lang="...">
--   fo:inline                   → <span style="..." lang="...">
--   fo:footnote / footnote-body → <fn>...</fn>
--   fo:float                    → <div style="float: top|bottom" lang="...">
--   fo:external-graphic         → <img>
--   fo:declarations/bg:font-face → @font-face { font-family; src }
--   xml:lang / language(+country) → HTML lang= (BCP47)
--   hyphenate="true|false"      → CSS hyphens: auto|none
--   xml:lang on fo:root         → htmlbag opts.lang (PDF /Lang)
--   bg:format on fo:root        → htmlbag opts.format ("PDF/UA" enables tagging)
--   fo:title (child of fo:root) → htmlbag opts.title (PDF /Title)
--   fo:block role="H1..H6"      → <h1>..<h6> (XSL-FO 1.1 §7.21.5 role)
--   fo:external-graphic alt=    → <img alt="…"> (Figure /Alt for PDF/UA)
-- Property mapping is a static table; complex compounds (space-before.optimum
-- etc.) are not unpacked. Multi-column, side-floats (start/end/inside/outside),
-- retrieve-marker, page-number-citation are deferred.
--
-- Note on RTL: htmlbag does not honour `dir="rtl"` or CSS `direction`. Bidi /
-- Arabic shaping is engaged automatically when the rendered text contains RTL
-- codepoints, so the .fo files just need the Arabic UTF-8 in place — no extra
-- direction property is mapped here. Hyphenation language IS routed through:
-- htmlbag reads HTML lang= and resolves it to a TeX hyphenation pattern set
-- (or a no-op for languages without patterns, such as Arabic).

local cxpath = require("xml.cxpath")

local FO_NS = "http://www.w3.org/1999/XSL/Format"
-- Extension namespace for non-standard helper elements (currently
-- bg:font-face). XSL-FO 1.1 §6.4.2 explicitly allows elements from any
-- other namespace under fo:declarations, which is what schema-aware
-- editors like oxygen XML look for.
local BG_NS = "https://boxesandglue.dev/ns/xslfo"

-- FO attribute → CSS property (1:1 mapping where possible).
local FO_TO_CSS = {
    ["font-family"]      = "font-family",
    ["font-size"]        = "font-size",
    ["font-weight"]      = "font-weight",
    ["font-style"]       = "font-style",
    ["color"]            = "color",
    ["background-color"] = "background-color",
    ["text-align"]       = "text-align",
    ["text-indent"]      = "text-indent",
    ["margin-left"]      = "margin-left",
    ["margin-right"]     = "margin-right",
    ["margin-top"]       = "margin-top",
    ["margin-bottom"]    = "margin-bottom",
    ["padding-left"]     = "padding-left",
    ["padding-right"]    = "padding-right",
    ["padding-top"]      = "padding-top",
    ["padding-bottom"]   = "padding-bottom",
    ["space-before"]     = "margin-top",
    ["space-after"]      = "margin-bottom",
    ["start-indent"]     = "padding-left",
    ["end-indent"]       = "padding-right",
    ["line-height"]      = "line-height",
}

-- Build the HTML lang= attribute from XSL-FO 1.1 §7.10:
--   xml:lang="en-US"          → lang="en-US"
--   language="en"             → lang="en"
--   language="en" country="US"→ lang="en-US"
-- Returns the empty string when no language information is present.
local function lang_attr(ctx)
    local xmllang = ctx:eval("@xml:lang").string
    if xmllang ~= "" then
        return ' lang="' .. escape(xmllang) .. '"'
    end
    local language = ctx:eval("@language").string
    if language == "" then return "" end
    local country = ctx:eval("@country").string
    if country == "" or country == "none" then
        return ' lang="' .. escape(language) .. '"'
    end
    return ' lang="' .. escape(language .. "-" .. country) .. '"'
end

-- Translate XSL-FO hyphenation properties to a CSS hyphens declaration.
-- XSL-FO 1.1 §7.10 uses hyphenate="true|false". CSS Text 3 §6 uses
-- hyphens: auto|manual|none. We map true→auto, false→none. The optional
-- intermediate value "manual" can be expressed via hyphenate="manual" as a
-- non-standard but intuitive extension; full CSS keyword is also accepted.
local function hyphens_decl(ctx)
    local v = ctx:eval("@hyphenate").string
    if v == "" then return "" end
    if v == "true" then return "hyphens:auto" end
    if v == "false" then return "hyphens:none" end
    if v == "auto" or v == "manual" or v == "none" then
        return "hyphens:" .. v
    end
    return ""
end

local function escape(s)
    return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function localname(ctx)
    return ctx:eval("local-name()").string
end

-- Build a CSS style string from the FO attributes on ctx that are in the
-- mapping table, plus any synthesized declarations such as hyphens. Empty
-- string if no mapped properties applied.
local function build_style(ctx)
    local parts = {}
    for foprop, cssprop in pairs(FO_TO_CSS) do
        local v = ctx:eval("@" .. foprop).string
        if v ~= "" then
            parts[#parts+1] = cssprop .. ":" .. v
        end
    end
    local h = hyphens_decl(ctx)
    if h ~= "" then parts[#parts+1] = h end
    return table.concat(parts, ";")
end

local function style_attr(ctx)
    local s = build_style(ctx)
    if s == "" then return "" end
    return ' style="' .. s .. '"'
end

-- walk_inline emits a sub-tree as inline content only — fo:block becomes a
-- transparent container (no <p>), used for footnote bodies and other places
-- where block-in-inline must collapse.
local function walk_inline(ctx, out)
    local name = localname(ctx)
    if name == "" then
        local txt = ctx.string
        if txt ~= "" then out[#out+1] = escape(txt) end
        return
    end
    if name == "inline" then
        out[#out+1] = "<span" .. style_attr(ctx) .. lang_attr(ctx) .. ">"
        for child in ctx:each("node()") do walk_inline(child, out) end
        out[#out+1] = "</span>"
    else
        -- fo:block, fo:footnote-body, anything else → just unwrap
        for child in ctx:each("node()") do walk_inline(child, out) end
    end
end

-- Recursive HTML emitter. Appends to the `out` array.
local function walk(ctx, out)
    local name = localname(ctx)

    if name == "" then
        -- Text node (or comment) — emit as escaped text.
        local txt = ctx.string
        if txt ~= "" then
            out[#out+1] = escape(txt)
        end
        return
    end

    if name == "block" then
        -- XSL-FO 1.1 §7.21.5 defines `role` as the structural role for
        -- Tagged PDF. We honour H1…H6 (and the lowercase variants) by
        -- emitting <h1>…<h6>, which htmlbag's PDF/UA pipeline tags as the
        -- corresponding heading structure elements (htmlToPDFRole map at
        -- htmlbag/tagging.go). All other roles fall through to <p>.
        local role = ctx:eval("@role").string
        local tag = "p"
        if role:match("^[Hh][1-6]$") then
            tag = role:lower()
        end
        out[#out+1] = "<" .. tag .. style_attr(ctx) .. lang_attr(ctx) .. ">"
        for child in ctx:each("node()") do walk(child, out) end
        out[#out+1] = "</" .. tag .. ">"

    elseif name == "inline" then
        out[#out+1] = "<span" .. style_attr(ctx) .. lang_attr(ctx) .. ">"
        for child in ctx:each("node()") do walk(child, out) end
        out[#out+1] = "</span>"

    elseif name == "footnote" then
        -- Drop the in-text fo:inline marker — htmlbag emits its own running
        -- number for <fn>. Walk only fo:footnote-body content as the fn body,
        -- using the inline walker so the inner fo:block does not become a
        -- block-level <p> inside the inline <fn>.
        out[#out+1] = "<fn>"
        for body in ctx:each("fo:footnote-body") do
            for child in body:each("node()") do walk_inline(child, out) end
        end
        out[#out+1] = "</fn>"

    elseif name == "float" then
        -- fo:float[@float="before"]   → <div style="float: top">    (top of page)
        -- fo:float[@float="after"]    → <div style="float: bottom"> (bottom of page)
        -- Default and unknown values are treated as "before" (top), matching
        -- the XSL-FO `float` property's default. Side-float values
        -- (start/end/inside/outside) currently fall through to top.
        --
        -- The @float attribute can't be read via `@float` or
        -- `attribute::float` in cxpath — both trip "childAxis nyi
        -- *goxml.Attribute", apparently because `float` is a reserved
        -- name in the XPath 2.0 grammar that the parser inherits.
        -- Reading via `name()`-filtered attribute iteration sidesteps
        -- the parse path that hits the conflict.
        local fofloat = ""
        for attr in ctx:each("@*") do
            if attr:eval("name()").string == "float" then
                fofloat = attr.string
                break
            end
        end
        local cssval = "top"
        if fofloat == "after" then
            cssval = "bottom"
        end
        local extra = build_style(ctx)
        local style = "float:" .. cssval
        if extra ~= "" then style = style .. ";" .. extra end
        out[#out+1] = '<div style="' .. style .. '"' .. lang_attr(ctx) .. '>'
        for child in ctx:each("node()") do walk(child, out) end
        out[#out+1] = '</div>'

    elseif name == "external-graphic" then
        -- htmlbag pulls image dimensions from the HTML width / height
        -- *attributes*, not from the CSS style string (inheritablestyles.go's
        -- "img" case reads item.Attributes["width" / "height"] directly).
        -- So @width / @height bypass build_style and become attributes.
        --
        -- @alt is non-standard XSL-FO but is the natural mapping to
        -- HTML's <img alt="…">. PDF/UA mode uses it to populate the
        -- Figure structure element's /Alt entry (htmlbag/vlistbuilder.go
        -- findImageAlt). Without it, an image cannot be PDF/UA-conformant.
        local src = ctx:eval("@src").string
        local imgw = ctx:eval("@width").string
        local imgh = ctx:eval("@height").string
        -- Collapse interior whitespace in alt-text. XML attribute value
        -- normalisation turns newlines into spaces but preserves runs of
        -- spaces, which leaves multi-line wrapped alt= attributes ugly
        -- in the PDF /Alt entry. Screen readers also benefit from a
        -- single-spaced reading.
        local imgalt = ctx:eval("@alt").string
        if imgalt ~= "" then
            imgalt = imgalt:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        end
        local parts = {'<img src="' .. escape(src) .. '"'}
        if imgw ~= "" then parts[#parts+1] = ' width="' .. escape(imgw) .. '"' end
        if imgh ~= "" then parts[#parts+1] = ' height="' .. escape(imgh) .. '"' end
        if imgalt ~= "" then parts[#parts+1] = ' alt="' .. escape(imgalt) .. '"' end
        parts[#parts+1] = style_attr(ctx)
        parts[#parts+1] = '/>'
        out[#out+1] = table.concat(parts)

    else
        -- Unknown FO element — pass through children (tolerant fallback so
        -- e.g. fo:list-block can degrade into a flat sequence of blocks).
        for child in ctx:each("node()") do walk(child, out) end
    end
end

-- Build CSS @page rule from the first fo:simple-page-master.
local function page_css(doc)
    for pm in doc:each("//fo:simple-page-master") do
        local function a(n) return pm:eval("@" .. n).string end
        local rules = {}
        local pw, ph = a("page-width"), a("page-height")
        if pw ~= "" and ph ~= "" then
            rules[#rules+1] = "size:" .. pw .. " " .. ph
        end
        local m = a("margin")
        if m ~= "" then rules[#rules+1] = "margin:" .. m end
        for _, side in ipairs({"top", "bottom", "left", "right"}) do
            local v = a("margin-" .. side)
            if v ~= "" then rules[#rules+1] = "margin-" .. side .. ":" .. v end
        end
        return "@page { " .. table.concat(rules, ";") .. " }"
    end
    return ""
end

-- Map fo:declarations/bg:font-face into @font-face CSS rules. XSL-FO 1.1
-- has no standard in-document font registration; FOP uses an external
-- config file, Antenna House uses axf:font-face. We mirror the CSS
-- @font-face shape under our own extension namespace (BG_NS) so
-- schema-aware editors (oxygen XML, etc.) accept the document — XSL-FO
-- §6.4.2 explicitly allows elements from any other namespace inside
-- fo:declarations.
--
-- Expected input:
--   <fo:declarations xmlns:bg="https://boxesandglue.dev/ns/xslfo">
--     <bg:font-face font-family="Amiri" src="amiri-regular.ttf"
--                   font-weight="normal" font-style="normal"/>
--   </fo:declarations>
local function font_face_css(doc)
    local rules = {}
    for ff in doc:each("//fo:declarations/bg:font-face") do
        local function a(n) return ff:eval("@" .. n).string end
        local family, src = a("font-family"), a("src")
        if family ~= "" and src ~= "" then
            local parts = {
                "font-family:'" .. family .. "'",
                "src:url('" .. src .. "')",
            }
            local w, s = a("font-weight"), a("font-style")
            if w ~= "" then parts[#parts+1] = "font-weight:" .. w end
            if s ~= "" then parts[#parts+1] = "font-style:" .. s end
            rules[#rules+1] = "@font-face { " .. table.concat(parts, ";") .. " }"
        end
    end
    return table.concat(rules, "\n")
end

-- Main
local input = nil
local writeHTML = false
local outOverride = nil
for i = 1, #arg do
    if arg[i] == "keep-html" then
        writeHTML = true
    elseif arg[i]:sub(1, 4) == "out=" then
        outOverride = arg[i]:sub(5)
    elseif input == nil then
        input = arg[i]
    end
end
if not input then
    error("usage: glu foproc.lua <input.fo> [keep-html] [out=NAME]")
end

local doc = cxpath.open(input)
doc:set_namespace("fo", FO_NS)
doc:set_namespace("bg", BG_NS)

-- read_attr returns the value of a named attribute on ctx, iterating
-- over @* and matching on name(). cxpath's @ns:name selector trips on
-- namespaced attributes (and strips the xml: prefix on xml:lang), so
-- this iteration form is the robust path. Same trick as the @float
-- handler in walk(), kept as a single helper to share between sites.
local function read_attr(ctx, ...)
    local wanted = {...}
    for attr in ctx:each("@*") do
        local n = attr:eval("name()").string
        for _, w in ipairs(wanted) do
            if n == w then return attr.string end
        end
    end
    return ""
end

-- Extract document-level metadata before walking the flow.
--   xml:lang on fo:root  → htmlbag opts.lang  → PDF /Lang catalog entry
--   bg:format on fo:root → htmlbag opts.format → "PDF/UA" enables tagging
--   <fo:title>…</fo:title> as direct child of fo:root → opts.title → PDF /Title
local meta = {}
do
    for r in doc:each("/fo:root") do
        local lang = read_attr(r, "xml:lang", "lang")
        if lang ~= "" then meta.lang = lang end
        local format = read_attr(r, "bg:format")
        if format ~= "" then meta.format = format end
        break
    end
    -- fo:title is a top-level XSL-FO element for the document title; we
    -- accept it as direct child of fo:root. string(.) on the title node
    -- returns its concatenated text content (XPath 1.0 §4.2).
    local title = doc:eval("string(/fo:root/fo:title)").string
    if title ~= "" then
        meta.title = title:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    end
end

local out = {}
out[#out+1] = "<!DOCTYPE html><html><head><style>"
out[#out+1] = page_css(doc)
out[#out+1] = font_face_css(doc)
-- XSL-FO traditionally derives the base writing direction from the
-- script of the content itself (htmlbag's pre-2026-05-20 default).
-- CSS Writing Modes 3 §2.4 expresses that as `unicode-bidi: plaintext`
-- — opt in here so existing Arabic/Hebrew FO docs keep their RTL
-- layout without needing an explicit `direction:` attribute.
out[#out+1] = "body { font-family: serif; font-size: 11pt; line-height: 1.4; unicode-bidi: plaintext; }"
out[#out+1] = "</style></head><body>"

-- Walk all top-level children of the body flow.
for child in doc:each("//fo:flow[@flow-name='xsl-region-body']/*") do
    walk(child, out)
end

out[#out+1] = "</body></html>"

local html_string = table.concat(out, "")

local pdf_filename
if outOverride then
    pdf_filename = outOverride
else
    pdf_filename = input:gsub("%.fo$", ".pdf")
    if pdf_filename == input then pdf_filename = input .. ".pdf" end
end

if writeHTML then
    local html_filename = input:gsub("%.fo$", ".html")
    if html_filename == input then html_filename = input .. ".html" end
    local f, err = io.open(html_filename, "w")
    if not f then error("could not open output: " .. err) end
    f:write(html_string)
    f:close()
    print("wrote " .. html_filename)
end

-- Hand the HTML to glu's HTML pipeline directly — no disk roundtrip.
-- Pass the document metadata through as an options table; the third
-- argument of htmlbag.render accepts either a base_dir string or an
-- options dict. base_dir defaults to "." which is what we want for
-- relative font/image paths.
local htmlbag = require("glu.htmlbag")
htmlbag.render(html_string, pdf_filename, {
    base_dir = ".",
    format   = meta.format,
    lang     = meta.lang,
    title    = meta.title,
})
