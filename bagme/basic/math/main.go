// Accessible mathematics with bagme.
//
// Inline and display MathML embedded in the HTML is typeset through the
// OpenType-MATH engine and — because the document is PDF/UA-2 — each formula
// is tagged as a Formula structure element carrying both a plain-text /Alt
// fallback and the MathML source as an associated file. Verify with:
//
//	pdfa11y out.pdf      # Verdict: PASS, incl. the MathML checks MH-17-*
package main

import (
	"log"
	"os"

	"github.com/boxesandglue/bagme/document"
)

func read(filename string) string {
	b, err := os.ReadFile(filename)
	if err != nil {
		panic(err)
	}
	return string(b)
}

func dothings() error {
	// WithPDFUA2 turns on PDF 2.0 + structure tagging; that is the single
	// switch that makes every <math> become an accessible Formula element.
	d, err := document.New("out.pdf", document.WithPDFUA2())
	if err != nil {
		return err
	}

	// PDF/UA requires a non-empty title and language.
	d.Title = "Mathematics with bagme"
	d.Language = "en"

	// styles.css registers the math font via @font-face — the engine needs a
	// font carrying an OpenType MATH table.
	if err = d.ReadCSSFile("styles.css"); err != nil {
		return err
	}

	if err = d.RenderPages(read("content.html")); err != nil {
		return err
	}

	return d.Finish()
}

func main() {
	if err := dothings(); err != nil {
		log.Fatal(err)
	}
}
