package main

import (
	"fmt"
	"log"

	"github.com/boxesandglue/bagme/document"
)

func dothings() error {
	d, err := document.New("out.pdf", document.WithPDFUA())
	if err != nil {
		return err
	}

	d.Title = "Table with Repeating Headers"
	d.Language = "en"

	if err = d.AddCSS(`
		@page { size: a5; margin: 1.5cm; }
		body { font-family: serif; font-size: 10pt; }
		h1 { font-size: 16pt; margin-bottom: 12pt; }
		table { width: 100%; }
		th {
			background-color: steelblue;
			color: white;
			padding: 4pt 6pt;
			border-bottom: 1pt solid steelblue;
		}
		td {
			padding: 3pt 6pt;
			border-bottom: 0.5pt solid lightgray;
		}
	`); err != nil {
		return err
	}

	// Build a long table that spans multiple pages.
	html := `<h1>Elements of the Periodic Table</h1><table><thead><tr><th>Nr.</th><th>Symbol</th><th>Element</th><th>Weight</th></tr></thead><tbody>`

	elements := []struct {
		symbol, name string
		number       int
		weight       string
	}{
		{symbol: "H", name: "Hydrogen", number: 1, weight: "1.008"},
		{symbol: "He", name: "Helium", number: 2, weight: "4.003"},
		{symbol: "Li", name: "Lithium", number: 3, weight: "6.941"},
		{symbol: "Be", name: "Beryllium", number: 4, weight: "9.012"},
		{symbol: "B", name: "Boron", number: 5, weight: "10.81"},
		{symbol: "C", name: "Carbon", number: 6, weight: "12.01"},
		{symbol: "N", name: "Nitrogen", number: 7, weight: "14.01"},
		{symbol: "O", name: "Oxygen", number: 8, weight: "16.00"},
		{symbol: "F", name: "Fluorine", number: 9, weight: "19.00"},
		{symbol: "Ne", name: "Neon", number: 10, weight: "20.18"},
		{symbol: "Na", name: "Sodium", number: 11, weight: "22.99"},
		{symbol: "Mg", name: "Magnesium", number: 12, weight: "24.31"},
		{symbol: "Al", name: "Aluminium", number: 13, weight: "26.98"},
		{symbol: "Si", name: "Silicon", number: 14, weight: "28.09"},
		{symbol: "P", name: "Phosphorus", number: 15, weight: "30.97"},
		{symbol: "S", name: "Sulfur", number: 16, weight: "32.07"},
		{symbol: "Cl", name: "Chlorine", number: 17, weight: "35.45"},
		{symbol: "Ar", name: "Argon", number: 18, weight: "39.95"},
		{symbol: "K", name: "Potassium", number: 19, weight: "39.10"},
		{symbol: "Ca", name: "Calcium", number: 20, weight: "40.08"},
		{symbol: "Sc", name: "Scandium", number: 21, weight: "44.96"},
		{symbol: "Ti", name: "Titanium", number: 22, weight: "47.87"},
		{symbol: "V", name: "Vanadium", number: 23, weight: "50.94"},
		{symbol: "Cr", name: "Chromium", number: 24, weight: "52.00"},
		{symbol: "Mn", name: "Manganese", number: 25, weight: "54.94"},
		{symbol: "Fe", name: "Iron", number: 26, weight: "55.85"},
		{symbol: "Co", name: "Cobalt", number: 27, weight: "58.93"},
		{symbol: "Ni", name: "Nickel", number: 28, weight: "58.69"},
		{symbol: "Cu", name: "Copper", number: 29, weight: "63.55"},
		{symbol: "Zn", name: "Zinc", number: 30, weight: "65.38"},
		{symbol: "Ga", name: "Gallium", number: 31, weight: "69.72"},
		{symbol: "Ge", name: "Germanium", number: 32, weight: "72.63"},
		{symbol: "As", name: "Arsenic", number: 33, weight: "74.92"},
		{symbol: "Se", name: "Selenium", number: 34, weight: "78.97"},
		{symbol: "Br", name: "Bromine", number: 35, weight: "79.90"},
		{symbol: "Kr", name: "Krypton", number: 36, weight: "83.80"},
		{symbol: "Rb", name: "Rubidium", number: 37, weight: "85.47"},
		{symbol: "Sr", name: "Strontium", number: 38, weight: "87.62"},
		{symbol: "Y", name: "Yttrium", number: 39, weight: "88.91"},
		{symbol: "Zr", name: "Zirconium", number: 40, weight: "91.22"},
	}

	for _, e := range elements {
		html += fmt.Sprintf("<tr><td>%d</td><td>%s</td><td>%s</td><td>%s</td></tr>",
			e.number, e.symbol, e.name, e.weight)
	}
	html += "</tbody></table>"

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
