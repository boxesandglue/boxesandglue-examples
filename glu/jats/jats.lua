-- jats.lua: turn a JATS article into HTML and typeset it with htmlbag.
--
-- A proof of concept, not a JATS processor. It walks the parts of JATS
-- (Journal Article Tag Suite, ANSI/NISO Z39.96) that a typical research
-- article uses and hands the HTML to glu's HTML pipeline; jats.css does
-- the layout. Unknown elements are unwrapped: their content is kept, the
-- element itself is dropped.
--
-- Usage: glu jats.lua <article.xml> [keep-html] [out=NAME]
--
--   keep-html  also writes the generated HTML next to the input
--   out=NAME   writes the PDF to NAME instead of <input>.pdf

local cxpath = require("xml.cxpath")
local htmlbag = require("glu.htmlbag")

local MML_NS = "http://www.w3.org/1998/Math/MathML"
local XLINK_NS = "http://www.w3.org/1999/xlink"

local doc -- the document context, set in main

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function escape(s)
    return (s:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function localname(ctx)
    return ctx:eval("local-name()").string
end

-- attr returns ' name="value"' for a non-empty value, else "" (also for
-- nil and false).
local function attr(name, value)
    if not value or value == "" then return "" end
    return " " .. name .. '="' .. escape(value) .. '"'
end

-- text returns the string value of xpath relative to ctx, with runs of
-- whitespace collapsed.
local function text(ctx, xpath)
    return (ctx:eval("normalize-space(" .. xpath .. ")").string)
end

--------------------------------------------------------------------------------
-- MathML: copied with the mml: prefix dropped
--------------------------------------------------------------------------------

local function mathml(ctx, out)
    local name = localname(ctx)
    if name == "" then
        out[#out + 1] = escape(ctx.string)
        return
    end
    out[#out + 1] = "<" .. name
    for a in ctx:each("@*") do
        out[#out + 1] = attr(localname(a), a.string)
    end
    out[#out + 1] = ">"
    for child in ctx:each("node()") do mathml(child, out) end
    out[#out + 1] = "</" .. name .. ">"
end

--------------------------------------------------------------------------------
-- Inline content
--------------------------------------------------------------------------------

local inline

local function inline_children(ctx, out)
    for child in ctx:each("node()") do inline(child, out) end
end

-- wrap returns a handler that puts the content into an HTML element.
local function wrap(tag, class)
    return function(ctx, out)
        out[#out + 1] = "<" .. tag .. attr("class", class) .. ">"
        inline_children(ctx, out)
        out[#out + 1] = "</" .. tag .. ">"
    end
end

-- footnote sets the paragraphs of the fn with the given id as a footnote at
-- the place of its reference; htmlbag numbers span.footnote itself.
local function footnote(id, out)
    local fn = doc:eval("//fn[@id='" .. id .. "']")
    out[#out + 1] = '<span class="footnote">'
    local first = true
    for p in fn:each("p") do
        if not first then out[#out + 1] = " " end
        inline_children(p, out)
        first = false
    end
    out[#out + 1] = "</span>"
end

local INLINE = {
    italic = wrap("i"),
    bold = wrap("b"),
    sup = wrap("sup"),
    sub = wrap("sub"),
    monospace = wrap("code"),
    sc = wrap("span", "smallcaps"),
    underline = wrap("u"),
    source = wrap("i"),
    ["inline-formula"] = inline_children,
    ["ext-link"] = function(ctx, out)
        out[#out + 1] = "<a" .. attr("href", ctx:eval("@xlink:href").string) .. ">"
        inline_children(ctx, out)
        out[#out + 1] = "</a>"
    end,
    xref = function(ctx, out)
        local reftype, rid = ctx:eval("@ref-type").string, ctx:eval("@rid").string
        if reftype == "fn" then
            footnote(rid, out)
            return
        end
        out[#out + 1] = "<a" .. attr("class", "xref " .. reftype) .. attr("href", "#" .. rid) .. ">"
        inline_children(ctx, out)
        out[#out + 1] = "</a>"
    end,
}

inline = function(ctx, out)
    local name = localname(ctx)
    if name == "" then
        out[#out + 1] = escape(ctx.string)
    elseif name == "math" then
        mathml(ctx, out)
    elseif INLINE[name] then
        INLINE[name](ctx, out)
    else
        inline_children(ctx, out)
    end
end

--------------------------------------------------------------------------------
-- Block content
--------------------------------------------------------------------------------

local block

local function block_children(ctx, out, level)
    for child in ctx:each("*") do block(child, out, level) end
end

-- caption returns the label and caption paragraphs of a fig or table-wrap
-- as inline HTML: "<span class="label">Figure 1.</span> text".
local function caption(ctx)
    local out = {}
    local label = text(ctx, "label")
    if label ~= "" then
        out[#out + 1] = '<span class="label">' .. escape(label) .. ".</span> "
    end
    for p in ctx:each("caption/p") do inline_children(p, out) end
    return table.concat(out)
end

-- copy_table copies the XHTML table model of JATS element by element;
-- the cells take inline content.
local function copy_table(ctx, out)
    local name = localname(ctx)
    if name == "th" or name == "td" then
        out[#out + 1] = "<" .. name .. attr("colspan", ctx:eval("@colspan").string)
            .. attr("rowspan", ctx:eval("@rowspan").string)
            .. attr("style", ctx:eval("@align").string ~= "" and "text-align:" .. ctx:eval("@align").string) .. ">"
        inline_children(ctx, out)
    else
        out[#out + 1] = "<" .. name .. ">"
        for child in ctx:each("*") do copy_table(child, out) end
    end
    out[#out + 1] = "</" .. name .. ">"
end

local BLOCK = {
    p = function(ctx, out)
        out[#out + 1] = "<p" .. attr("id", ctx:eval("@id").string) .. ">"
        inline_children(ctx, out)
        out[#out + 1] = "</p>"
    end,
    sec = function(ctx, out, level)
        local h = "h" .. math.min(level + 1, 6)
        out[#out + 1] = "<section" .. attr("id", ctx:eval("@id").string) .. ">"
        out[#out + 1] = "<" .. h .. ">"
        local label = text(ctx, "label")
        if label ~= "" then
            out[#out + 1] = '<span class="label">' .. escape(label) .. "</span> "
        end
        for t in ctx:each("title") do inline_children(t, out) end
        out[#out + 1] = "</" .. h .. ">"
        for child in ctx:each("*[not(self::label or self::title)]") do
            block(child, out, level + 1)
        end
        out[#out + 1] = "</section>"
    end,
    list = function(ctx, out, level)
        local tag = ctx:eval("@list-type").string == "order" and "ol" or "ul"
        out[#out + 1] = "<" .. tag .. ">"
        for item in ctx:each("list-item") do
            out[#out + 1] = "<li>"
            block_children(item, out, level)
            out[#out + 1] = "</li>"
        end
        out[#out + 1] = "</" .. tag .. ">"
    end,
    ["disp-quote"] = function(ctx, out, level)
        out[#out + 1] = "<blockquote>"
        block_children(ctx, out, level)
        out[#out + 1] = "</blockquote>"
    end,
    fig = function(ctx, out)
        out[#out + 1] = "<figure" .. attr("id", ctx:eval("@id").string) .. ">"
        for g in ctx:each("graphic") do
            out[#out + 1] = "<img" .. attr("src", g:eval("@xlink:href").string)
                .. attr("alt", text(ctx, "alt-text")) .. ">"
        end
        out[#out + 1] = "<figcaption>" .. caption(ctx) .. "</figcaption></figure>"
    end,
    ["table-wrap"] = function(ctx, out)
        out[#out + 1] = "<table" .. attr("id", ctx:eval("@id").string) .. ">"
        out[#out + 1] = "<caption>" .. caption(ctx) .. "</caption>"
        for part in ctx:each("table/*") do copy_table(part, out) end
        out[#out + 1] = "</table>"
    end,
    -- A display formula is a paragraph with two tab stops: the formula
    -- centered, the label at the right margin (see jats.css).
    ["disp-formula"] = function(ctx, out)
        out[#out + 1] = '<p class="disp-formula"' .. attr("id", ctx:eval("@id").string) .. ">\t"
        for m in ctx:each("mml:math") do mathml(m, out) end
        out[#out + 1] = "\t" .. escape(text(ctx, "label")) .. "</p>"
    end,
}

block = function(ctx, out, level)
    local handler = BLOCK[localname(ctx)]
    if handler then
        handler(ctx, out, level)
    else
        block_children(ctx, out, level)
    end
end

--------------------------------------------------------------------------------
-- Front and back matter
--------------------------------------------------------------------------------

local function front(out)
    local meta = doc:eval("/article/front/article-meta")
    local journal = text(doc, "/article/front/journal-meta//journal-title")
    local volume, issue = text(meta, "volume"), text(meta, "issue")
    local year = text(meta, "pub-date[1]/year")
    local doi = text(meta, "article-id[@pub-id-type='doi']")
    out[#out + 1] = '<p class="journal">' .. escape(journal)
    if volume ~= "" then
        out[#out + 1] = " " .. escape(volume)
        if issue ~= "" then out[#out + 1] = "(" .. escape(issue) .. ")" end
    end
    if year ~= "" then out[#out + 1] = ", " .. escape(year) end
    if doi ~= "" then out[#out + 1] = ". doi:" .. escape(doi) end
    out[#out + 1] = "</p>"

    out[#out + 1] = "<h1>"
    for t in meta:each("title-group/article-title") do inline_children(t, out) end
    out[#out + 1] = "</h1>"

    local authors = {}
    for c in meta:each("contrib-group/contrib[@contrib-type='author']") do
        local a = { escape(text(c, "name/given-names") .. " " .. text(c, "name/surname")) }
        for x in c:each("xref[@ref-type='aff']") do inline_children(x, a) end
        authors[#authors + 1] = table.concat(a)
    end
    out[#out + 1] = '<p class="authors">' .. table.concat(authors, ", ") .. "</p>"

    out[#out + 1] = '<div class="affiliations">'
    for aff in meta:each("aff") do
        out[#out + 1] = "<p" .. attr("id", aff:eval("@id").string) .. "><sup>"
            .. escape(text(aff, "label")) .. "</sup> "
        for child in aff:each("node()[not(self::label)]") do inline(child, out) end
        out[#out + 1] = "</p>"
    end
    out[#out + 1] = "</div>"

    for abstract in meta:each("abstract") do
        out[#out + 1] = '<div class="abstract"><h2>Abstract</h2>'
        block_children(abstract, out, 1)
        local kwds = {}
        for k in meta:each("kwd-group/kwd") do kwds[#kwds + 1] = escape(k.string) end
        if #kwds > 0 then
            out[#out + 1] = '<p class="keywords"><b>Keywords:</b> ' .. table.concat(kwds, ", ") .. "</p>"
        end
        out[#out + 1] = "</div>"
    end
end

local function back(out)
    for ack in doc:each("/article/back/ack") do
        out[#out + 1] = '<section class="ack"><h2>' .. escape(text(ack, "title")) .. "</h2>"
        for child in ack:each("*[not(self::title)]") do block(child, out, 1) end
        out[#out + 1] = "</section>"
    end
    for refs in doc:each("/article/back/ref-list") do
        out[#out + 1] = '<section class="references"><h2>' .. escape(text(refs, "title")) .. "</h2><ol>"
        for ref in refs:each("ref") do
            out[#out + 1] = "<li" .. attr("id", ref:eval("@id").string) .. ">"
                .. '<span class="label">[' .. escape(text(ref, "label")) .. "]</span> "
            for cit in ref:each("mixed-citation | element-citation") do inline_children(cit, out) end
            out[#out + 1] = "</li>"
        end
        out[#out + 1] = "</ol></section>"
    end
end

--------------------------------------------------------------------------------
-- Main
--------------------------------------------------------------------------------

local input, keep_html, pdf_filename
for i = 1, #arg do
    if arg[i] == "keep-html" then
        keep_html = true
    elseif arg[i]:sub(1, 4) == "out=" then
        pdf_filename = arg[i]:sub(5)
    elseif input == nil then
        input = arg[i]
    end
end
if not input then
    error("usage: glu jats.lua <article.xml> [keep-html] [out=NAME]")
end
local stem = input:gsub("%.xml$", "")
pdf_filename = pdf_filename or stem .. ".pdf"

doc = cxpath.open(input)
doc:set_namespace("mml", MML_NS):set_namespace("xlink", XLINK_NS)

local out = { '<!DOCTYPE html><html><head><link rel="stylesheet" href="jats.css"></head><body>' }
front(out)
out[#out + 1] = '<div class="body">'
block_children(doc:eval("/article/body"), out, 1)
back(out)
out[#out + 1] = "</div></body></html>"
local html = table.concat(out)

if keep_html then
    local f = assert(io.open(stem .. ".html", "w"))
    f:write(html)
    f:close()
    print("wrote " .. stem .. ".html")
end

htmlbag.render(html, pdf_filename, {
    base_dir = ".",
    lang = doc:eval("/article/@xml:lang").string,
    title = text(doc, "/article/front/article-meta/title-group/article-title"),
})
