package main

import (
	"log"

	"github.com/boxesandglue/bagme/document"
	"github.com/boxesandglue/boxesandglue/backend/bag"
)

func dothings() error {
	d, err := document.New("out.pdf", document.WithPDFUA())
	if err != nil {
		return err
	}

	d.Title = "Positioned Elements"
	d.Language = "en"

	if err = d.AddCSS(`
		@page { size: a5; margin: 0; }
		body { font-family: serif; font-size: 11pt; }
		h1 { font-size: 22pt; color: darkslateblue; }
		.label { font-size: 9pt; color: gray; }
		.card {
			border: 0.5pt solid steelblue;
			border-radius: 4pt;
			padding: 8pt;
			background-color: aliceblue;
		}
	`); err != nil {
		return err
	}

	width := bag.MustSP("90mm")

	// Title at top (y measured from bottom edge)
	if err = d.OutputAt(
		`<h1>Positioned Layout</h1>`,
		width,
		bag.MustSP("2cm"), bag.MustSP("19cm"),
	); err != nil {
		return err
	}

	// Card 1
	if err = d.OutputAt(
		`<div class="card"><p>This card is placed at an <em>absolute position</em> on
		the page. Bagme uses the OutputAt method to render HTML snippets at
		exact coordinates.</p></div>`,
		width,
		bag.MustSP("2cm"), bag.MustSP("15cm"),
	); err != nil {
		return err
	}

	// Card 2 — offset to the right and lower on the page
	if err = d.OutputAt(
		`<div class="card"><p>A second card, offset to the right and placed below
		the first. Each call to OutputAt renders independently — there is no
		automatic flow between snippets.</p></div>`,
		width,
		bag.MustSP("4cm"), bag.MustSP("11cm"),
	); err != nil {
		return err
	}

	// Label at bottom
	if err = d.OutputAt(
		`<p class="label">Generated with bagme — boxes and glue</p>`,
		width,
		bag.MustSP("2cm"), bag.MustSP("2cm"),
	); err != nil {
		return err
	}

	return d.Finish()
}

func main() {
	if err := dothings(); err != nil {
		log.Fatal(err)
	}
}
