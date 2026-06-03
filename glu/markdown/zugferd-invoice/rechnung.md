---
title: Rechnung
author: Lieferant GmbH
lang: de
papersize: a4
format: PDF/A-3b
css: rechnung.css
---

<div class="letterhead">
<strong>{= zugferd.seller.name =}</strong><br>
{= zugferd.seller.line1 =}<br>
{= zugferd.seller.zip =} {= zugferd.seller.city =}
</div>

<div class="addressblock">
{= zugferd.buyer.name =}<br>
{= zugferd.buyer.line1 =}<br>
{= zugferd.buyer.zip =} {= zugferd.buyer.city =}
</div>

<div class="meta">
Rechnungsnummer: <strong>{= zugferd.id =}</strong><br>
Rechnungsdatum: {= zugferd.date =}<br>
Währung: {= zugferd.currency =}
</div>

# Rechnung Nr. {= zugferd.id =}

Sehr geehrte Damen und Herren,

vielen Dank für Ihren Auftrag. Wir stellen Ihnen folgende Positionen in Rechnung:

```{lua}
local out = {
    "| Pos. | Artikel | Menge | Preis | Gesamt |",
    "| ---: | --- | ---: | ---: | ---: |",
}
for _, l in ipairs(zugferd.lines) do
    table.insert(out, string.format(
        "| %s | %s | %s | %s %s | %s %s |",
        l.pos, l.name, l.qty,
        l.price, zugferd.currency,
        l.line_total, zugferd.currency))
end
return table.concat(out, "\n")
```

<div class="totals">
Summe netto: {= zugferd.line_total =} {= zugferd.currency =}<br>
zzgl. Mehrwertsteuer: {= zugferd.tax_total =} {= zugferd.currency =}<br>
<strong>Gesamtbetrag: {= zugferd.total =} {= zugferd.currency =}</strong>
</div>

{= zugferd.payment_terms =}

Mit freundlichen Grüßen

{= zugferd.seller.name =}
