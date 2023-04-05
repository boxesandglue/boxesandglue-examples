package main

import (
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/speedata/boxesandglue/backend/bag"
	"github.com/speedata/boxesandglue/frontend"
)

var (
	str = `In olden times when wishing still helped one, there lived a king whose daughters
	were all beautiful; and the youngest was so beautiful that the sun itself, which
	has seen so much, was astonished whenever it shone in her face.
	Close by the king's castle lay a great dark forest, and under an old lime-tree in the forest
	was a well, and when the day was very warm, the king's child went out into the
	forest and sat down by the side of the cool fountain; and when she was bored she
	took a golden ball, and threw it up on high and caught it; and this ball was her
	favorite plaything.`
)

// common setup for examples
func setup(title string) (*frontend.Document, error) {
	f, err := frontend.New("sample.pdf")
	if err != nil {
		return nil, err
	}

	f.Doc.Title = title

	if f.Doc.DefaultLanguage, err = frontend.GetLanguage("en"); err != nil {
		return nil, err
	}

	// Load a font, define a font family, and add this font to the family.
	ff := f.NewFontFamily("text")
	ff.AddMember(
		&frontend.FontSource{Source: "../../fonts/crimsonpro/CrimsonPro-Regular.ttf"},
		frontend.FontWeight400,
		frontend.FontStyleNormal,
	)
	return f, nil
}

func typesetSample() error {
	f, err := setup("The frog king")
	if err != nil {
		return err
	}

	// Create a recursive data structure for typesetting initialized with the
	// text from the top (but with space normalized).
	para := frontend.NewText()
	para.Items = []any{strings.Join(strings.Fields(str), " ")}

	// Format the text into a paragraph. Some of these settings (font family and
	// font size) can be part of the typesetting element.
	vlist, _, err := f.FormatParagraph(para, bag.MustSp("125pt"),
		frontend.Leading(bag.MustSp("14pt")),
		frontend.FontSize(bag.MustSp("12pt")),
		frontend.Family(f.FindFontFamily("text")),
	)
	if err != nil {
		return err
	}

	// Output the text and finish the page and the PDF file.
	p := f.Doc.NewPage()
	p.OutputAt(bag.MustSp("1cm"), bag.MustSp("26cm"), vlist)
	p.Shipout()
	if err = f.Doc.Finish(); err != nil {
		return err
	}
	return nil
}

func main() {
	starttime := time.Now()
	err := typesetSample()
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("finished in ", time.Now().Sub(starttime))
}
