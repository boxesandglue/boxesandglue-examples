package main

import (
	"fmt"
	"log"

	"github.com/boxesandglue/boxesandglue/backend/bag"
	"github.com/boxesandglue/boxesandglue/backend/document"
	"github.com/boxesandglue/boxesandglue/backend/node"
	"github.com/boxesandglue/boxesandglue/frontend"
)

// Tab stops are set per paragraph with SettingTabStops. A tab character in
// the text advances to the next stop past the text before it; the stop's
// alignment says how the text after the tab lines up with it. Once the stops
// run out a tab keeps its usual width (SettingTabSize).

var (
	ff    *frontend.FontFamily
	page  *document.Page
	y     = bag.MustSP("27cm")
	hsize = bag.MustSP("150mm")
)

// place formats te as a paragraph of hsize and puts it below the previous
// one, followed by a gap.
func place(f *frontend.Document, te *frontend.Text, gap bag.ScaledPoint, opts ...frontend.TypesettingOption) error {
	opts = append(opts,
		frontend.Family(ff),
		frontend.FontSize(bag.MustSP("11pt")),
		frontend.Leading(bag.MustSP("14pt")),
	)
	vl, _, err := f.FormatParagraph(te, hsize, opts...)
	if err != nil {
		return err
	}
	page.OutputAt(bag.MustSP("3cm"), y, vl)
	y -= vl.Height + vl.Depth + gap
	return nil
}

// caption sets a short description above an example.
func caption(f *frontend.Document, s string) error {
	te := frontend.NewText()
	te.Settings[frontend.SettingColor] = "gray"
	te.Items = []any{s}
	return place(f, te, bag.MustSP("3mm"), frontend.FontSize(bag.MustSP("9pt")))
}

// example sets str with the given stops.
func example(f *frontend.Document, str string, stops ...frontend.TabStop) error {
	te := frontend.NewText()
	te.Settings[frontend.SettingTabStops] = stops
	te.Items = []any{str}
	return place(f, te, bag.MustSP("9mm"))
}

func typeset() error {
	f, err := frontend.New("result.pdf")
	if err != nil {
		return err
	}
	f.Doc.Title = "Tab stops"
	if f.Doc.DefaultLanguage, err = frontend.GetLanguage("en"); err != nil {
		return err
	}
	ff = f.NewFontFamily("text")
	if err = ff.AddMember(
		&frontend.FontSource{Location: "../../fonts/crimsonpro/CrimsonPro-Regular.ttf"},
		frontend.FontWeight400,
		frontend.FontStyleNormal,
	); err != nil {
		return err
	}
	page = f.Doc.NewPage()

	// Left stop: the value starts at the stop whatever the width of the
	// label. Lines are separated by newlines (forced breaks).
	if err = caption(f, "Left stop at 40 mm: values line up whatever the width of the label"); err != nil {
		return err
	}
	if err = example(f, "Name\tAlice Example\nPostal address\tBob Street 12, 12345 Sample City\nE-mail\talice@example.com",
		frontend.TabStop{Position: bag.MustSP("40mm")},
	); err != nil {
		return err
	}

	// A contents line: a left stop for the title and a right stop at the
	// measure with a dot leader, so the page numbers end at the right edge.
	if err = caption(f, "Contents line: left stop at 12 mm, right stop at the measure with a dot leader"); err != nil {
		return err
	}
	if err = example(f, "1\tIntroduction\t3\n2\tThe line breaker\t17\n2.1\tTab stops as reset points\t121",
		frontend.TabStop{Position: bag.MustSP("12mm")},
		frontend.TabStop{Position: hsize, Align: node.TabAlignRight, Leader: " . "},
	); err != nil {
		return err
	}

	// Decimal stops line figures up on their separator, "." unless the stop
	// names another one. A figure without a separator ends at the stop.
	if err = caption(f, "Decimal stops at 60 mm (separator \".\") and 110 mm (separator \",\")"); err != nil {
		return err
	}
	if err = example(f, "Apples\t3.5\t1.234,50\nPears\t12.75\t7,5\nTotal\t1234\t12.345,00",
		frontend.TabStop{Position: bag.MustSP("60mm"), Align: node.TabAlignDecimal},
		frontend.TabStop{Position: bag.MustSP("110mm"), Align: node.TabAlignDecimal, Separator: ","},
	); err != nil {
		return err
	}

	// A center stop centers the text after the tab on the stop.
	if err = caption(f, "Center stop at 75 mm"); err != nil {
		return err
	}
	if err = example(f, "\tcentered on the stop\n\tx\n\ta much longer run, centered as well",
		frontend.TabStop{Position: bag.MustSP("75mm"), Align: node.TabAlignCenter},
	); err != nil {
		return err
	}

	// Text that has passed a stop goes on to the next one. After the last
	// stop a tab has its usual width.
	if err = caption(f, "Stops at 25 mm and 70 mm: text past a stop goes on to the next, then tabs keep their own width"); err != nil {
		return err
	}
	if err = example(f, "ab\tfirst stop\tsecond stop\tno stop left\nA much longer label\tsecond stop\tno stop left",
		frontend.TabStop{Position: bag.MustSP("25mm")},
		frontend.TabStop{Position: bag.MustSP("70mm")},
	); err != nil {
		return err
	}

	// Tabs inside a paragraph that wraps: the line breaker knows the width
	// each tab will get, so the lines are broken accordingly.
	if err = caption(f, "A left stop at 100 mm inside a paragraph that wraps"); err != nil {
		return err
	}
	if err = example(f, "In olden times when wishing still helped one, there lived a king whose daughters were all beautiful;\tand the youngest was so beautiful that the sun itself, which has seen so much, was astonished whenever it shone in her face. Close by the king's castle lay a great dark forest,\tand under an old lime-tree in the forest was a well.",
		frontend.TabStop{Position: bag.MustSP("100mm")},
	); err != nil {
		return err
	}

	page.Shipout()
	return f.Doc.Finish()
}

func main() {
	if err := typeset(); err != nil {
		log.Fatal(err)
	}
	fmt.Println("result.pdf written")
}
