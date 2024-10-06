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
	pw.DefaultPageHeight = 290
	pw.DefaultPageWidth = 400

	img, err := pw.LoadImageFile("ocean.pdf")
	if err != nil {
		return err
	}

	scale := 0.45
	posX := 10.0
	posY := 10.0

	stream := pw.NewObject()
	stream.Data.WriteString(fmt.Sprintf("q %f 0 0 %f %f %f cm %s Do Q\n", scale, scale, posX, posY, img.InternalName()))
	page1 := pw.AddPage(stream, 0)
	page1.Images = append(page1.Images, img)

	pw.Finish()
	return nil
}

func main() {
	if err := dothings(); err != nil {
		log.Fatal(err)
	}
}
