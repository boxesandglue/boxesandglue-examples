local cxpath = require("xml.cxpath")

local M = {}

-- attach_zugferd attaches ZUGFeRD XML to the document
function M.attach_zugferd(doc, filename, conformancelevel, visiblename, description)
    conformancelevel = conformancelevel or "COMFORT"
    visiblename = visiblename or "factur-x.xml"
    description = description or "ZUGFeRD invoice"

    doc.format = "PDF/A-3b"

    doc:attach_file({
        filename = filename,
        mimetype = "text/xml",
        description = description,
        name = visiblename,
    })

    doc:add_xmp_extension({
        schema = "ZUGFeRD PDFA Extension Schema",
        namespace_uri = "urn:ferd:pdfa:CrossIndustryDocument:invoice:1p0#",
        prefix = "zf",
        properties = {
            { name = "DocumentFileName", value_type = "Text", category = "external", description = "name of the embedded XML invoice file" },
            { name = "DocumentType",     value_type = "Text", category = "external", description = "INVOICE" },
            { name = "Version",          value_type = "Text", category = "external", description = "The actual version of the ZUGFeRD data" },
            { name = "ConformanceLevel", value_type = "Text", category = "external", description = "The conformance level of the ZUGFeRD data" },
        },
        values = {
            ConformanceLevel = conformancelevel,
            DocumentFileName = visiblename,
            DocumentType     = "INVOICE",
            Version          = "1.0",
        },
    })
end

-- Open and parse the ZUGFeRD XML
local zugferdXML = cxpath.open("zugferd.xml")
zugferdXML:set_namespace("rsm", "urn:un:unece:uncefact:data:standard:CrossIndustryInvoice:100")
zugferdXML:set_namespace("qdt", "urn:un:unece:uncefact:data:standard:QualifiedDataType:100")
zugferdXML:set_namespace("ram", "urn:un:unece:uncefact:data:standard:ReusableAggregateBusinessInformationEntity:100")
zugferdXML:set_namespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")
zugferdXML:set_namespace("xsd", "http://www.w3.org/2001/XMLSchema")
zugferdXML:set_namespace("udt", "urn:un:unece:uncefact:data:standard:UnqualifiedDataType:100")

local rootName = "/rsm:CrossIndustryInvoice"
local supplyChainTradeTransactionName = rootName .. "/rsm:SupplyChainTradeTransaction"
local applicableHeaderTradeAgreementName = supplyChainTradeTransactionName .. "/ram:ApplicableHeaderTradeAgreement"
local sellerTradePartyName = applicableHeaderTradeAgreementName .. "/ram:SellerTradeParty"
local buyerTradePartyName = applicableHeaderTradeAgreementName .. "/ram:BuyerTradeParty"
local lineItemName = supplyChainTradeTransactionName .. "/ram:IncludedSupplyChainTradeLineItem"

function M.get_address(who)
    local party
    if who == "seller" then
        party = zugferdXML:eval(sellerTradePartyName)
    else
        party = zugferdXML:eval(buyerTradePartyName)
    end

    local ret = string.format("%s\n%s\n",
        party:eval("ram:Name").string,
        party:eval("ram:PostalTradeAddress/ram:LineOne").string)

    local linetwo = party:eval("ram:PostalTradeAddress/ram:LineTwo").string
    if linetwo ~= "" then
        ret = ret .. string.format("%s\n", linetwo)
    end

    ret = ret .. string.format("%s %s",
        party:eval("ram:PostalTradeAddress/ram:PostcodeCode").string,
        party:eval("ram:PostalTradeAddress/ram:CityName").string)

    return ret
end

function M.get_address_short(who)
    local party
    if who == "seller" then
        party = zugferdXML:eval(sellerTradePartyName)
    else
        party = zugferdXML:eval(buyerTradePartyName)
    end

    return string.format("%s · %s · %s %s",
        party:eval("ram:Name").string,
        party:eval("ram:PostalTradeAddress/ram:LineOne").string,
        party:eval("ram:PostalTradeAddress/ram:PostcodeCode").string,
        party:eval("ram:PostalTradeAddress/ram:CityName").string)
end

function M.get_date()
    local rawdate = zugferdXML:eval("/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:IssueDateTime/udt:DateTimeString").string
    return string.format("%s.%s.%s", string.sub(rawdate, 7, 8), string.sub(rawdate, 5, 6), string.sub(rawdate, 1, 4))
end

function M.get_invoice_lines()
    local invoiceLines = {}
    for line in zugferdXML:each(lineItemName) do
        table.insert(invoiceLines, {
            pos = line:eval("ram:AssociatedDocumentLineDocument/ram:LineID").string,
            description = line:eval("ram:SpecifiedTradeProduct/ram:Name").string,
            amount = line:eval("ram:SpecifiedLineTradeAgreement/ram:NetPriceProductTradePrice/ram:ChargeAmount").string,
            quantity = line:eval("ram:SpecifiedLineTradeDelivery/ram:BilledQuantity").string,
            unit = line:eval("ram:SpecifiedLineTradeDelivery/ram:BilledQuantity/@unitCode").string,
            tax = line:eval("ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:RateApplicablePercent").string,
            taxcode = line:eval("ram:SpecifiedLineTradeSettlement/ram:ApplicableTradeTax/ram:TypeCode").string,
            totalamount = line:eval("ram:SpecifiedLineTradeSettlement/ram:SpecifiedTradeSettlementLineMonetarySummation/ram:LineTotalAmount").string,
        })
    end
    return invoiceLines
end

function M.get_invoice_summation()
    local invoiceLines = {}
    local summation = zugferdXML:eval("/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction/ram:ApplicableHeaderTradeSettlement/ram:SpecifiedTradeSettlementHeaderMonetarySummation")
    table.insert(invoiceLines, {"Summe", summation:eval("ram:LineTotalAmount").string})
    table.insert(invoiceLines, {"Steuerbetrag", summation:eval("ram:TaxTotalAmount").string})
    table.insert(invoiceLines, {"Gesamtbetrag", summation:eval("ram:GrandTotalAmount").string})
    return invoiceLines
end

function M.get_reginfo()
    return zugferdXML:eval("/rsm:CrossIndustryInvoice/rsm:ExchangedDocument/ram:IncludedNote[2]/ram:Content").string
end

function M.get_invoice_number()
    return zugferdXML:eval(rootName .. "/rsm:ExchangedDocument/ram:ID").string
end

function M.get_payment_terms()
    return zugferdXML:eval("/rsm:CrossIndustryInvoice/rsm:SupplyChainTradeTransaction[1]/ram:ApplicableHeaderTradeSettlement[1]/ram:SpecifiedTradePaymentTerms[1]/ram:Description[1]").string
end

return M
