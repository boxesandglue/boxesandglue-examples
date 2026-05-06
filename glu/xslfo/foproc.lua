-- foproc.lua — proof-of-concept XSL-FO → HTML transformer.
--
-- Run as:  glu foproc.lua <input.fo>             → <input>.pdf
--          glu foproc.lua <input.fo> keep-html   → <input>.pdf and <input>.html
--                                                  (writes the intermediate
--                                                   HTML out for inspection /
--                                                   debugging)
-- Note: the keep-html marker is a positional keyword, not a `--flag`,
-- because glu reserves `--html` for its own debug output flag and
-- swallows it before the script sees it.
--
-- Coverage:
--   fo:simple-page-master       → @page { size, margin }
--   fo:flow                     → <body>
--   fo:block                    → <p style="...">
--   fo:inline                   → <span style="...">
--   fo:footnote / footnote-body → <fn>...</fn>
--   fo:float                    → <div style="float: top|bottom">
--   fo:external-graphic         → <img>
-- Property mapping is a static table; complex compounds (space-before.optimum
-- etc.) are not unpacked. Multi-column, side-floats (start/end/inside/outside),
-- retrieve-marker, page-number-citation are deferred.

local cxpath = require("xml.cxpath")

local FO_NS = "http://www.w3.org/1999/XSL/Format"

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

local function escape(s)
    return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function localname(ctx)
    return ctx:eval("local-name()").string
end

-- Build a CSS style string from the FO attributes on ctx that are in the
-- mapping table. Empty string if no mapped attributes.
local function build_style(ctx)
    local parts = {}
    for foprop, cssprop in pairs(FO_TO_CSS) do
        local v = ctx:eval("@" .. foprop).string
        if v ~= "" then
            parts[#parts+1] = cssprop .. ":" .. v
        end
    end
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
        out[#out+1] = "<span" .. style_attr(ctx) .. ">"
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
        out[#out+1] = "<p" .. style_attr(ctx) .. ">"
        for child in ctx:each("node()") do walk(child, out) end
        out[#out+1] = "</p>"

    elseif name == "inline" then
        out[#out+1] = "<span" .. style_attr(ctx) .. ">"
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
        out[#out+1] = '<div style="' .. style .. '">'
        for child in ctx:each("node()") do walk(child, out) end
        out[#out+1] = '</div>'

    elseif name == "external-graphic" then
        local src = ctx:eval("@src").string
        out[#out+1] = '<img src="' .. escape(src) .. '"' .. style_attr(ctx) .. '/>'

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

-- Main
local input = nil
local writeHTML = false
for i = 1, #arg do
    if arg[i] == "keep-html" then
        writeHTML = true
    elseif input == nil then
        input = arg[i]
    end
end
if not input then
    error("usage: glu foproc.lua <input.fo> [keep-html]")
end

local doc = cxpath.open(input)
doc:set_namespace("fo", FO_NS)

local out = {}
out[#out+1] = "<!DOCTYPE html><html><head><style>"
out[#out+1] = page_css(doc)
out[#out+1] = "body { font-family: serif; font-size: 11pt; line-height: 1.4; }"
out[#out+1] = "</style></head><body>"

-- Walk all top-level children of the body flow.
for child in doc:each("//fo:flow[@flow-name='xsl-region-body']/*") do
    walk(child, out)
end

out[#out+1] = "</body></html>"

local html_string = table.concat(out, "")

local pdf_filename = input:gsub("%.fo$", ".pdf")
if pdf_filename == input then pdf_filename = input .. ".pdf" end

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
local htmlbag = require("glu.htmlbag")
htmlbag.render(html_string, pdf_filename)
