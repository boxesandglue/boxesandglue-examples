package main

import (
	"log"
	"os"

	"github.com/boxesandglue/bagme/document"
)

func dothings() error {
	// Read the Factur-X XML invoice data.
	xmlData, err := os.ReadFile("factur-x.xml")
	if err != nil {
		return err
	}

	// Create a ZUGFeRD-compliant PDF. WithZUGFeRD automatically:
	// - sets PDF/A-3b format
	// - attaches the XML as "factur-x.xml"
	// - adds the required XMP extension schema
	d, err := document.New("out.pdf",
		document.WithZUGFeRD(xmlData, "EN16931"))
	if err != nil {
		return err
	}

	d.Title = "Rechnung 471102"
	d.Author = "Lieferant GmbH"
	d.Language = "de"

	if err = d.AddCSS(`
		@page { size: a4; margin: 2cm; }
		body { font-family: sans-serif; font-size: 10pt; }
		h1 { font-size: 18pt; margin-bottom: 6pt; }
		h2 { font-size: 12pt; margin-bottom: 4pt; color: #333; }
		table { width: 100%; margin-top: 12pt; }
		th {
			background-color: #2c3e50;
			color: white;
			padding: 4pt 6pt;
			border-bottom: 1pt solid #2c3e50;
		}
		td {
			padding: 3pt 6pt;
			border-bottom: 0.5pt solid #ddd;
		}
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
<p>USt. 19% auf 198,00 €: 37,62 €</p>
<p>USt. 7% auf 275,00 €: 19,25 €</p>
<p class="total">Gesamtbetrag: 529,87 €</p>

<p>Zahlbar innerhalb 30 Tagen netto bis 15.12.2024, 3% Skonto innerhalb 10 Tagen bis 25.11.2024</p>`

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
