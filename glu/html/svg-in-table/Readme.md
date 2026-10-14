# Inline SVG in table cells

A dashboard-style table with three columns and one inline
`<svg width="100%">` in each cell. Each SVG is sized against the
content width of its own cell.

## What this exercises

A `<td>` that holds an inline `<svg width="100%">` shows the SVG at
the full content width of the cell (the cell width minus its padding).
htmlbag sizes the SVG once the table layout has fixed the cell width,
so the percentage refers to the cell and not to the page. The cells
use `vertical-align: top` and `padding: 6pt`, and the header and label
rows are plain text cells.

## Run

```
glu svg-in-table.html -o out.pdf
```

This produces `out.pdf`. The directory ships a copy as `result.pdf`
and a rendered preview as `firstpage.png`.

## Column widths

In this example the three columns are equally wide, so the three SVGs
come out at the same width. The SVGs follow whatever cell width the
table layout produces: with different column widths, for example from
`<col style="width: ...">` in a `<colgroup>`, each SVG takes the width
of its own cell.
