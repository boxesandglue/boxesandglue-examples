// Combined-conformance ZUGFeRD invoice: PDF/A-3b for archival + embedded
// XML, PDF/UA-1 for accessibility. Before bagme's Format-as-Struct refactor
// each WithPDFx option overwrote the previous one, so this composition
// silently dropped the PDF/UA declaration.
package main

import (
	"log"
	"os"

	"github.com/boxesandglue/bagme/document"
)

func dothings() error {
	xmlData, err := os.ReadFile("factur-x.xml")
	if err != nil {
		return err
	}

	// Both options additive: WithPDFUA() sets only the PDFUA sub-
	// conformance, WithZUGFeRD() sets only the PDFA sub-conformance
	// (plus attachment + XMP extension). Final Format declares both.
	d, err := document.New("out.pdf",
		document.WithPDFUA(),
		document.WithZUGFeRD(xmlData, "EN16931"),
	)
	if err != nil {
		return err
	}

	// PDF/UA requires a non-empty Title and Language for /DisplayDocTitle
	// and StructTreeRoot /Lang to be valid.
	d.Title = "Rechnung 471102 (barrierefrei)"
	d.Author = "Lieferant GmbH"
	d.Language = "de"

	if err = d.AddCSS(`
		@page { size: a4; margin: 2cm; }
		body { font-family: sans-serif; font-size: 10pt; }
		h1 { font-size: 18pt; margin-bottom: 6pt; }
		h2 { font-size: 12pt; margin-bottom: 4pt; color: #333; }
		table { width: 100%; margin-top: 12pt; }
		th { background-color: #2c3e50; color: white; padding: 4pt 6pt; }
		td { padding: 3pt 6pt; border-bottom: 0.5pt solid #ddd; }
		.total { font-weight: bold; }
	`); err != nil {
		return err
	}

	html := `<h1>Rechnung Nr. 471102</h1>
<h2>Lieferant GmbH</h2>
<p>Lieferantenstraße 20, 80333 München</p>

<h2>Kunde</h2>
<p>Kunden AG Mitte<br>Kundenstraße 15, 69876 Frankfurt</p>

<p>Rechnungsdatum: 15.11.2024</p>

<table>
<thead><tr><th>Pos.</th><th>Artikel</th><th>Menge</th><th>Einzelpreis</th><th>Gesamt</th></tr></thead>
<tbody>
<tr><td>1</td><td>Trennblätter A4</td><td>20</td><td>9,90 €</td><td>198,00 €</td></tr>
<tr><td>2</td><td>Joghurt Banane</td><td>50</td><td>5,50 €</td><td>275,00 €</td></tr>
</tbody>
</table>

<p>Nettobetrag: 473,00 €</p>
<p class="total">Gesamtbetrag: 529,87 €</p>`

	if err = d.RenderPages(html); err != nil {
		return err
	}
	return d.Finish()
}

func main() {
	if err := dothings(); err != nil {
		log.Fatal(err)
	}
}
