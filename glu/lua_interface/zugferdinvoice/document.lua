local frontend = require("glu.frontend")
local node = require("glu.node")

local M = {}

local ff = nil  -- font family

function M.setup_fonts(f)
    ff = f:new_font_family("text")

    local regular = frontend.fontsource({
        location = "../../fonts/crimsonpro/CrimsonPro-Regular.ttf",
        features = {"kern", "liga"},
    })
    local bold = frontend.fontsource({
        location = "../../fonts/crimsonpro/CrimsonPro-Bold.ttf",
        features = {"kern", "liga"},
    })

    ff:add_member({source = regular, weight = 400, style = "normal"})
    ff:add_member({source = bold, weight = 700, style = "normal"})
    return ff
end

function M.render_logo(doc, p)
    local imgfile = doc:load_imagefile("img/logo.pdf")
    local imgNode = doc:create_image_node(imgfile, 1, "/MediaBox")
    imgNode.width = "112.8pt"
    imgNode.height = "28.8pt"
    local vl = node.vpack(imgNode)
    p:output_at("19cm" - imgNode.width, "290mm", vl)
end

function M.render_address(f, p, sellershort, buyer)
    local para = frontend.text()
    para.items = {sellershort}
    local vlist = f:format_paragraph(para, "120mm", {
        leading = "10pt",
        fontsize = "8pt",
        fontfamily = ff,
    })
    p:output_at("2cm", "253mm", vlist)

    para = frontend.text()
    para.items = {buyer}
    vlist = f:format_paragraph(para, "80mm", {
        leading = "14pt",
        fontsize = "12pt",
        fontfamily = ff,
    })
    p:output_at("2cm", "248mm", vlist)
end

function M.render_docinfo(f, p, seller)
    local para = frontend.text()
    para.settings.halign = "right"
    para.items = {seller}
    local vlist = f:format_paragraph(para, "170mm", {
        fontsize = "12pt",
        leading = "14pt",
        fontfamily = ff,
    })
    p:output_at("2cm", "253mm", vlist)
end

-- Returns the new y position
function M.render_text(f, p, y, text)
    local para = frontend.text()
    para.settings.halign = "left"
    para.items = {text}
    local vlist = f:format_paragraph(para, "165mm", {
        leading = "14pt",
        fontsize = "12pt",
        fontfamily = ff,
    })
    p:output_at("2.5cm", y, vlist)
    return y - vlist.height
end

-- helper functions
local function to_unit(code)
    if code == "H87" then
        return "Stk."
    end
    return code
end

local function add_text(tr, text, weight, align)
    weight = weight or 400
    align = align or "left"

    local tdText = frontend.text()
    tdText.settings.fontfamily = ff
    tdText.settings.fontweight = weight
    tdText.settings.halign = align
    tdText.items = {text}

    local td = tr:new_cell()
    td:append(tdText)
    return td
end

function M.build_table(frontend_doc, invoice_lines, invoice_summation)
    local tbl = frontend.table()
    local tr = tbl:new_row()

    local td
    td = add_text(tr, "Pos", 700, "center")
    td.padding_bottom = "1mm"
    td = add_text(tr, "Menge", 700, "center")
    td.padding_bottom = "1mm"
    td = add_text(tr, "Einheit", 700, "center")
    td.padding_bottom = "1mm"
    td = add_text(tr, "Text", 700, "center")
    td.padding_bottom = "1mm"
    td = add_text(tr, "EP", 700, "center")
    td.padding_bottom = "1mm"
    td = add_text(tr, "Gesamt", 700, "center")
    td.padding_bottom = "1mm"
    td = add_text(tr, "Steuer", 700, "center")
    td.padding_bottom = "1mm"

    for _, line in ipairs(invoice_lines) do
        tr = tbl:new_row()
        add_text(tr, line.pos, 400, "center")
        add_text(tr, string.format("%.2f", tonumber(line.quantity)), 400, "right")
        add_text(tr, to_unit(line.unit), 400, "center")
        add_text(tr, line.description)
        add_text(tr, string.format("%.2f €", tonumber(line.amount)), 400, "right")
        add_text(tr, line.totalamount .. " €", 400, "right")
        add_text(tr, line.tax .. "%", 400, "right")
    end

    for l, line in ipairs(invoice_summation) do
        tr = tbl:new_row()
        for i = 1, 5 do
            tr:new_cell()
        end
        local txt_td = add_text(tr, line[1], 400)
        local value_td = add_text(tr, line[2] .. " €", 400, "right")
        if l == 1 then
            txt_td.padding_top = "0.5cm"
            value_td.padding_top = "0.5cm"
        else
            txt_td.padding_top = "0.2cm"
            value_td.padding_top = "0.2cm"
        end
    end

    tbl.max_width = "16.5cm"
    tbl.stretch = true
    local vls = frontend_doc:build_table(tbl)
    return vls[1]
end

return M
