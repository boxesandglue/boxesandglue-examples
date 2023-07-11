package main

import (
	"fmt"
	"log"
	"time"

	"github.com/speedata/boxesandglue/backend/bag"
	"github.com/speedata/boxesandglue/frontend"
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
		&frontend.FontSource{Location: "../../fonts/crimsonpro/CrimsonPro-Regular.ttf"},
		frontend.FontWeight400,
		frontend.FontStyleNormal,
	)
	return f, nil
}

func doCell(input string, f *frontend.Document) *frontend.TableCell {
	settings := frontend.TypesettingSettings{
		frontend.SettingFontFamily: f.FindFontFamily("text"),
		frontend.SettingSize:       10 * bag.Factor,
	}
	borderwidth := bag.MustSp("0.5pt")

	cell := &frontend.TableCell{
		BorderBottomWidth: borderwidth,
		BorderLeftWidth:   borderwidth,
		BorderRightWidth:  borderwidth,
		BorderTopWidth:    borderwidth,
		BorderTopColor:    f.GetColor("black"),
		BorderBottomColor: f.GetColor("blue"),
		BorderLeftColor:   f.GetColor("green"),
		BorderRightColor:  f.GetColor("rebeccapurple"),
		HAlign:            frontend.HAlignLeft,
	}
	cell.Contents = append(cell.Contents, &frontend.Text{
		Settings: settings,
		Items:    []any{input},
	})
	return cell
}

func dorow(f *frontend.Document) *frontend.TableRow {
	row := &frontend.TableRow{
		VAlign: frontend.VAlignTop,
	}
	row.Cells = append(row.Cells, doCell("A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart.", f))
	row.Cells = append(row.Cells, doCell("Hello nice world", f))
	return row
}

func typesetSample() error {
	f, err := setup("Table example")
	f.Doc.DefaultPageWidth = bag.MustSp("200pt")
	f.Doc.DefaultPageHeight = bag.MustSp("4cm")

	table := &frontend.Table{}
	table.Rows = append(table.Rows, dorow(f))
	table.Rows = append(table.Rows, dorow(f))
	table.MaxWidth = f.Doc.DefaultPageWidth - bag.MustSp("20pt")
	table.Stretch = false

	// BuildTable can (in the future) return multiple vertical lists for tables
	// broken across pages. We are currently only interested in the first entry.
	vls, err := f.BuildTable(table)
	if err != nil {
		return err
	}
	// Output the text and finish the page and the PDF file.
	p := f.Doc.NewPage()
	p.OutputAt(bag.MustSp("10pt"), p.Height-bag.MustSp("10pt"), vls[0])
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
