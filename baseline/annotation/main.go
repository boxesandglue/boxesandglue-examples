package main

import (
	"fmt"
	"log"
	"os"
	"strings"

	pdf "github.com/boxesandglue/baseline-pdf"
	"github.com/boxesandglue/textlayout/harfbuzz"
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

	text := "boxesandglue.dev"

	// text shaping turns a text into code points and positions
	buf := harfbuzz.NewBuffer()
	buf.AddRunes([]rune(text), 0, -1)
	buf.GuessSegmentProperties()
	buf.Shape(face.HarfbuzzFont, []harfbuzz.Feature{})
	codepoints := []int{}

	// let's start with a 12 pt font and output at (100,100)
	data := []string{fmt.Sprintf("BT %s 12 Tf 10 100 Td <", face.InternalName())}
	for _, v := range buf.Info {
		// I ignore kerns and other positioning for the sake of simplicity
		data = append(data, fmt.Sprintf("%04x", int(v.Glyph)))
		codepoints = append(codepoints, int(v.Glyph))
	}
	face.RegisterChars(codepoints)
	data = append(data, "> Tj ET")
	stream := pw.NewObject()
	stream.Data.WriteString(strings.Join(data, ""))
	if err = stream.Save(); err != nil {
		return err
	}
	page := pw.AddPage(stream, 0)
	page.Faces = append(page.Faces, face)
	hl := pdf.Annotation{
		Subtype: "Link",
		Action:  "<</Type/Action/S/URI/URI (https://boxesandglue.dev)>>",
		Rect:    [4]float64{10, 98, 98, 110},
	}
	page.Annotations = append(page.Annotations, hl)
	pw.Finish()

	return nil
}

func main() {
	if err := dothings(); err != nil {
		log.Fatal(err)
	}
}
