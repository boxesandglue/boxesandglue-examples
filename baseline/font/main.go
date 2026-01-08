package main

import (
	"fmt"
	"log"
	"os"
	"strings"

	pdf "github.com/boxesandglue/baseline-pdf"
	"github.com/boxesandglue/textshape/ot"
)

func dothings() error {
	w, err := os.Create("out.pdf")
	if err != nil {
		return err
	}
	defer w.Close()
	pw := pdf.NewPDFWriter(w)
	pw.DefaultPageWidth = 300
	pw.DefaultPageHeight = 300

	face, err := pw.LoadFace("../../fonts/crimsonpro/CrimsonPro-Regular.ttf", 0)
	if err != nil {
		return err
	}

	text := "Hello, world!"

	// text shaping turns a text into code points and positions
	buf := ot.NewBuffer()
	buf.AddString(text)
	buf.GuessSegmentProperties()
	face.Shaper.Shape(buf, nil)

	// Collect glyph IDs and register them for subsetting
	codepoints := []int{}
	for _, v := range buf.Info {
		codepoints = append(codepoints, int(v.GlyphID))
	}
	face.RegisterCodepoints(codepoints)

	// Simple workflow: use original glyph IDs directly
	// (PrepareSubset not called → FlagRetainGIDs is used automatically)
	data := []string{fmt.Sprintf("BT %s 12 Tf 100 100 Td <", face.InternalName())}
	for _, v := range buf.Info {
		data = append(data, fmt.Sprintf("%04x", int(v.GlyphID)))
	}
	data = append(data, "> Tj ET")
	stream := pw.NewObject()
	stream.Data.WriteString(strings.Join(data, ""))
	if err = stream.Save(); err != nil {
		return err
	}
	page := pw.AddPage(stream, 0)
	page.Faces = append(page.Faces, face)
	pw.Finish()

	return nil
}

func main() {
	if err := dothings(); err != nil {
		log.Fatal(err)
	}
}
