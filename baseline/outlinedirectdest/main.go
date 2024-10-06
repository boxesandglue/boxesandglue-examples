package main

import (
	"fmt"
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
	o := &pdf.Outline{
		Title: "Top left",
		Open:  true,
		Dest:  fmt.Sprintf("[ %s /Fit ]", p.Objnum.Ref()),
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
