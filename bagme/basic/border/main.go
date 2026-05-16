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
	d, err := document.New("out.pdf")
	if err != nil {
		return err
	}

	if err = d.ReadCSSFile("styles.css"); err != nil {
		return err
	}

	if err = d.RenderPages(read("chunk.html")); err != nil {
		return err
	}

	return d.Finish()
}

func main() {
	if err := dothings(); err != nil {
		log.Fatal(err)
	}
}
