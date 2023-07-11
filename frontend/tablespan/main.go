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
		HAlign:            frontend.HAlignLeft,
	}
	cell.Contents = append(cell.Contents, &frontend.Text{
		Settings: settings,
		Items:    []any{input},
	})

	return cell
}

func dorow(f *frontend.Document, r int) *frontend.TableRow {
	row := &frontend.TableRow{
		VAlign: frontend.VAlignTop,
	}
	for c := 0; c < 3; c++ {
		cell := doCell(fmt.Sprintf("text at x: %d, y: %d", c+1, r), f)
		if r == 1 && c == 1 {
			// don't add because of colspan
		} else if r == 3 && c == 1 {
			// don't add because of rowspan
		} else {
			if r == 2 && c == 1 {
				cell.ExtraRowspan = 1
			} else if r == 1 && c == 0 {
				cell.ExtraColspan = 1
			}
			row.Cells = append(row.Cells, cell)
		}
	}

	return row
}

func typesetSample() error {
	f, err := setup("Table example")
	f.Doc.DefaultPageWidth = bag.MustSp("240pt")
	f.Doc.DefaultPageHeight = bag.MustSp("7cm")

	table := &frontend.Table{}
	table.Rows = append(table.Rows, dorow(f, 1))
	table.Rows = append(table.Rows, dorow(f, 2))
	table.Rows = append(table.Rows, dorow(f, 3))
	table.MaxWidth = f.Doc.DefaultPageWidth - bag.MustSp("20pt")

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
