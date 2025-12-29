local frontend = require("glu.frontend")
local glu = require("glu")
local node = require("glu.node")

local zugferd = require("zugferd")
local doc_module = require("document")

local doc = frontend.new("out.pdf")

local colorprofile = doc:load_colorprofile("AdobeRGB1998.icc")
colorprofile.identifier = "AdobeRGB1998"
colorprofile.registry = "Adobe"
colorprofile.info = "Adobe RGB (1998)"
colorprofile.condition = "RGB"
colorprofile.colors = 3

zugferd.attach_zugferd(doc, "zugferd.xml")
doc.language = doc:get_language("de")

doc.title = "Rechnung " .. zugferd.get_invoice_number()
doc.subject = "Rechnung"
doc.author = "boxes and glue"

local fontfamily = doc_module.setup_fonts(doc)

local p = doc:new_page()
p.width = "210mm"
p.height = "297mm"

doc_module.render_logo(doc, p)

local cury = doc_module.render_text(doc, p, "194mm",
    "Rechnung " .. zugferd.get_invoice_number() .. "\n\nSehr geehrte Damen und Herren,\n\nwir bedanken uns für Ihren Einkauf und stellen folgende Positionen in Rechnung")

local tbl = doc_module.build_table(doc, zugferd.get_invoice_lines(), zugferd.get_invoice_summation())
p:output_at("2.5cm", cury - "1cm", tbl)

cury = cury - tbl.height - "2cm"
doc_module.render_text(doc, p, cury,
    zugferd.get_payment_terms() .. "\n\nWir bitten um Überweisung des Gesamtbetrags auf unser Konto. Wir danken Ihnen für Ihr Vertrauen und freuen uns auf Ihren nächsten Einkauf.\n\nMit freundlichen Grüßen\n\nboxes and glue")

doc_module.render_address(doc, p, zugferd.get_address_short("seller"), zugferd.get_address("buyer"))

local str = zugferd.get_reginfo() .. "\n\n" .. zugferd.get_date()
doc_module.render_docinfo(doc, p, str)

p:shipout()
doc:finish()
