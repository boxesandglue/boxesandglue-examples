-- Companion Lua for rechnung.md. glu auto-loads <stem>.lua before any
-- {lua} blocks or {= … =} inline expressions run, so this is where we
-- (a) parse the structured ZUGFeRD/Factur-X XML once and expose its fields
-- as a Lua global, and (b) register a document_start callback that flips
-- the PDF to PDF/A-3b, loads the sRGB output intent, attaches the XML as
-- factur-x.xml, and writes the ZUGFeRD XMP extension schema.
--
-- glu itself has no ZUGFeRD-specific code. Everything below is plain
-- frontend / cxpath / xml-bag scripting — the same primitives any other
-- compliance format (XRechnung, PEPPOL, DIN 5008, …) would build on.

local frontend = require("glu.frontend")
local cxpath = require("xml.cxpath")

-- Resolve invoice.xml relative to this script's directory rather than cwd.
local script_dir = (arg[0]:match("^(.*)/") or ".")
local xml_path = script_dir .. "/invoice.xml"

-- ----------------------------------------------------------------------
-- 1. Parse the CII XML into a flat `zugferd` global so the Markdown body
--    can use {= zugferd.id =}, {= zugferd.buyer.name =} etc.
-- ----------------------------------------------------------------------

local doc = cxpath.open(xml_path)
doc:set_namespace("rsm", "urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100")
doc:set_namespace("ram", "urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100")
doc:set_namespace("udt", "urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100")

local function s(expr)
    local r = doc:eval(expr)
    return (r and r.string) or ""
end

local function read_address(base)
    local name    = s(base .. "/ram:Name")
    local line1   = s(base .. "/ram:PostalTradeAddress/ram:LineOne")
    local line2   = s(base .. "/ram:PostalTradeAddress/ram:LineTwo")
    local zip     = s(base .. "/ram:PostalTradeAddress/ram:PostcodeCode")
    local city    = s(base .. "/ram:PostalTradeAddress/ram:CityName")
    return {
        name    = name,
        line1   = line1,
        line2   = line2,
        zip     = zip,
        city    = city,
        country = s(base .. "/ram:PostalTradeAddress/ram:CountryID"),
        vat_id  = s(base .. "/ram:SpecifiedTaxRegistration/ram:ID"),
    }
end

local function format_date(raw)
    if #raw == 8 then
        return raw:sub(7, 8) .. "." .. raw:sub(5, 6) .. "." .. raw:sub(1, 4)
    end
    return raw
end

local lines = {}
for line in doc:each("/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:IncludedSupplyChainTradeLineItem") do
    table.insert(lines, {
        pos        = line:eval("ram:AssociatedDocumentLineDocument/ram:LineID").string,
        name       = line:eval("ram:SpecifiedTradeProduct/ram:Name").string,
        qty        = line:eval("ram:SpecifiedLineTradeDelivery/ram:BilledQuantity").string,
        unit       = line:eval("ram:SpecifiedLineTradeDelivery/ram:BilledQuantity/@unitCode").string,
        price      = line:eval("ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount").string,
        tax        = line:eval("ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:RateApplicablePercent").string,
        line_total = line:eval("ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount").string,
    })
end

zugferd = {
    id             = s("/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:ID"),
    date           = format_date(s("/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:IssueDateTime/udt:DateTimeString")),
    currency       = s("/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:InvoiceCurrencyCode"),
    seller         = read_address("/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:SellerTradeParty"),
    buyer          = read_address("/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeAgreement/ram:BuyerTradeParty"),
    lines          = lines,
    line_total     = s("/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:LineTotalAmount"),
    tax_total      = s("/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:TaxTotalAmount"),
    total          = s("/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation/ram:GrandTotalAmount"),
    payment_terms  = s("/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradePaymentTerms/ram:Description"),
}

-- ----------------------------------------------------------------------
-- 2. ZUGFeRD/Factur-X PDF compliance: output intent, attachment and XMP
--    extension schema. The page_init callback gives us the live document
--    on the first page; document_start fires before frontend.New(...) has
--    run, so we cannot use it here.
--
--    Format = PDF/A-3b is set in the Markdown frontmatter, not here.
-- ----------------------------------------------------------------------

local initialized = false

frontend.add_callback("page_init", "zugferd-compliance", function(d, _page, pagenum)
    if initialized then return end
    initialized = true

    -- PDF/A-3 requires an output intent. AdobeRGB is shipped with this
    -- example as AdobeRGB1998.icc; swap for any sRGB / CMYK profile your
    -- workflow requires.
    local cp = d:load_colorprofile(script_dir .. "/AdobeRGB1998.icc")
    cp.identifier = "AdobeRGB1998"
    cp.registry   = "Adobe"
    cp.info       = "Adobe RGB (1998)"
    cp.condition  = "RGB"
    cp.colors     = 3

    d:attach_file({
        filename    = xml_path,
        name        = "factur-x.xml",
        mimetype    = "text/xml",
        description = "Factur-X/ZUGFeRD invoice",
    })

    d:add_xmp_extension({
        schema        = "ZUGFeRD PDFA Extension Schema",
        namespace_uri = "urn:ferd:pdfa:CrossIndustryDocument:invoice:1p0#",
        prefix        = "zf",
        properties = {
            { name = "DocumentFileName", value_type = "Text", category = "external", description = "name of the embedded XML invoice file" },
            { name = "DocumentType",     value_type = "Text", category = "external", description = "INVOICE" },
            { name = "Version",          value_type = "Text", category = "external", description = "The actual version of the ZUGFeRD data" },
            { name = "ConformanceLevel", value_type = "Text", category = "external", description = "The conformance level of the ZUGFeRD data" },
        },
        values = {
            ConformanceLevel = "EN 16931",
            DocumentFileName = "factur-x.xml",
            DocumentType     = "INVOICE",
            Version          = "1.0",
        },
    })
end)
