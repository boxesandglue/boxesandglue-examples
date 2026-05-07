# boxes and glue — examples

Working examples for the [boxes and glue](https://boxesandglue.dev/)
PDF typesetting library: a Go port of TeX-style line breaking and
page layout, with high-level wrappers for HTML, Markdown, XSL-FO and
direct Lua scripting.

The examples are split by which layer of the stack they exercise:

* **[glu](glu)** — the scripting tool: HTML, Markdown, XSL-FO, Lua
* **[frontend](#frontend)** — the high-level Go API: paragraphs,
  tables, font families
* **[baseline](#baseline)** — the low-level PDF writer:
  pages, fonts, annotations, outlines, image embedding
* **[fonts](fonts)** — shared font assets used by several examples

Every example ships a runnable source file, a generated PDF, and (for
PDF-producing examples) a `firstpage.png` preview rendered with
`pdftoppm` at 150 dpi.

## glu

See [`glu/Readme.md`](glu) for the full thematic listing — HTML
floats, an XSL-FO walker, Markdown barcodes / slides, and direct Lua
bindings (text shaping, ZUGFeRD invoices).

Pick of the pack:

Description | Preview
--- | ---
[Floats / inserts](glu/html/floats) — top / bottom floats and footnotes via plain CSS | <a href="glu/html/floats"><img src="glu/html/floats/04-mixed-classes/firstpage.png" width="200"></a>
[XSL-FO walker](glu/xslfo) — XSL-FO front matter handed to htmlbag | <a href="glu/xslfo"><img src="glu/xslfo/01-basic/firstpage.png" width="200"></a>
[PDF/UA tagging](glu/xslfo/10-pdfua) — ISO 14289-1 accessibility | <a href="glu/xslfo/10-pdfua"><img src="glu/xslfo/10-pdfua/firstpage.png" width="200"></a>
[Markdown slides](glu/markdown/slides) — 16:9 deck from Markdown | <a href="glu/markdown/slides"><img src="glu/markdown/slides/slides-preview.png" width="200"></a>
[Barcodes](glu/markdown/barcodes) — EAN-13, Code 128, QR via the `<barcode>` element | <a href="glu/markdown/barcodes"><img src="glu/markdown/barcodes/firstpage.png" width="200"></a>
[ZUGFeRD invoice](glu/lua_interface/zugferdinvoice) — EN 16931 PDF/A-3 | <a href="glu/lua_interface/zugferdinvoice"><img src="glu/lua_interface/zugferdinvoice/firstpage.png" width="200"></a>

## frontend

The high-level Go API — `frontend.Document`, font families, paragraph
formatting, tables. Run any example with `go run main.go` from inside
its directory.

Description | Preview
--- | ---
[Hello world](frontend/helloworld) — smallest end-to-end frontend program | <a href="frontend/helloworld"><img src="frontend/helloworld/firstpage.png" width="200"></a>
[Simple table](frontend/simpletable) — row / column basics | <a href="frontend/simpletable"><img src="frontend/simpletable/firstpage.png" width="200"></a>
[Table with cell spans](frontend/tablespan) — `colspan` / `rowspan` from XML | <a href="frontend/tablespan"><img src="frontend/tablespan/firstpage.png" width="200"></a>

## baseline

The low-level `baseline-pdf` writer — direct PDF object construction,
no frontend layer, no paragraph builder. Useful for understanding
what the higher levels add (and for the rare case where you need to
emit PDF objects by hand). Run any example with `go run main.go`.

Description | Preview
--- | ---
[Simple PDF](baseline/simplepdf) — minimal two-page document | <a href="baseline/simplepdf"><img src="baseline/simplepdf/firstpage.png" width="200"></a>
[Font](baseline/font) — load a font and write a glyph | <a href="baseline/font"><img src="baseline/font/firstpage.png" width="200"></a>
[Image](baseline/image) — import a PDF as a Form XObject | <a href="baseline/image"><img src="baseline/image/firstpage.png" width="200"></a>
[Annotation (hyperlink)](baseline/annotation) — clickable URI annotation | <a href="baseline/annotation"><img src="baseline/annotation/firstpage.png" width="200"></a>
[Outline — direct destinations](baseline/outlinedirectdest) — bookmarks pointing at explicit `/XYZ` views | <a href="baseline/outlinedirectdest"><img src="baseline/outlinedirectdest/firstpage.png" width="200"></a>
[Outline — named destinations](baseline/outlinenamedest) — bookmarks via the catalog `/Names` dictionary | <a href="baseline/outlinenamedest"><img src="baseline/outlinenamedest/firstpage.png" width="200"></a>

## fonts

Shared font assets used by several examples (loaded via relative
paths from the example directory). Currently:

* `fonts/crimsonpro/` — Crimson Pro (SIL Open Font Licence 1.1) in
  Regular / Italic / Bold / BoldItalic.

## Documentation

* Library handbook: <https://doc.speedata.de/boxesandglue/>
* glu handbook: <https://boxesandglue.dev/glu/>
* htmlbag handbook: <https://doc.speedata.de/htmlbag/>
* hobby curve library: <https://boxesandglue.dev/hobby/>
