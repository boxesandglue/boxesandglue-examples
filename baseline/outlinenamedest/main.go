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
	pw.DefaultPageHeight = 500 // dtp point
	pw.DefaultPageWidth = 300

	// The contents of the page. A simple rectangle
	// starting at 0,0 and width 300 and height 500
	stream := pw.NewObject()
	stream.Data.WriteString("10 10 280 480 re s")
	if err = stream.Save(); err != nil {
		return err
	}
	p := pw.AddPage(stream, 0)
	// top left
	d := &pdf.NameDest{
		X:                0,
		Y:                500,
		PageObjectnumber: p.Objnum,
		Name:             "A destination",
	}
	pw.NameDestinations[d.Name] = d
	d = &pdf.NameDest{
		X:                0,
		Y:                200,
		PageObjectnumber: p.Objnum,
		Name:             "another destination",
	}
	pw.NameDestinations[d.Name] = d
	o := &pdf.Outline{
		Title: "Top left",
		Open:  true,
		Dest:  pdf.Serialize(pdf.String("A destination")),
	}
	pw.Outlines = append(pw.Outlines, o)
	o = &pdf.Outline{
		Title: "Somewhere on the first page",
		Open:  true,
		Dest:  pdf.Serialize(pdf.String("another destination")),
	}
	pw.Outlines = append(pw.Outlines, o)
	pw.Finish()

	return nil
}

func main() {
	if err := dothings(); err != nil {
		log.Fatal(err)
	}
}
