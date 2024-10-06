package main

import (
	"log"
	"os"

	pdf "github.com/boxesandglue/baseline-pdf"
)

func dothings() error {
	w, err := os.Create("out.pdf")
	if err != nil {
		return err
	}
	defer w.Close()
	pw := pdf.NewPDFWriter(w)
	pw.DefaultPageHeight = 510 // dtp point
	pw.DefaultPageWidth = 310
	pw.DefaultOffsetX = -10
	pw.DefaultOffsetY = -10

	// The contents of the page. A simple rectangle
	// starting at 0,0 and width 300 and height 500
	stream := pw.NewObject()
	stream.Data.WriteString("0 0 300 500 re s")
	if err = stream.Save(); err != nil {
		return err
	}

	// The first page has the default dimensions.
	// When you pass 0 as the second argument, the pages object
	// will be created for you.
	// Since we don't want to do anything else with the created page,
	// the return value is discarded.
	pw.AddPage(stream, 0)

	// Page 2 has the same contents, but a different
	// viewpoint:
	page2 := pw.AddPage(stream, 0)
	page2.Width = 100
	page2.Height = 100
	page2.OffsetX = -100
	page2.OffsetY = -100

	pw.Finish()

	return nil
}

func main() {
	if err := dothings(); err != nil {
		log.Fatal(err)
	}
}
