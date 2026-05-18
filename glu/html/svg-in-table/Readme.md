# Inline SVG in table cells

Dashboard-style three-column table with one inline `<svg width="100%">`
per cell. Each SVG materialises against its cell's `paraWidth` via the
DeferredSizer table-cell hook in `htmlbag/htmltable.go`.

## What this exercises

Before the table-cell hook, a `<td><svg width="100%"/></td>` cell
rendered as an empty cell. `frontend.cell.build()` accepts only
`*Text` and `FormatToVList` in `Contents`, so a raw `*node.VList`
(the inline-svg wrapper) was silently dropped from the cell. Even
when the SVG sat inside a wrapping `*Text` and reached
`FormatParagraph`, the linebreaker dropped the VList from the line
output. Either way the chart never appeared.

The hook in `buildTD` short-circuits when a non-box cell-content Text
contains exactly one VList carrying a `DeferredSizer`. It wraps the
VList in a `FormatToVList` closure that materialises the sizer at
the cell's actual `paraWidth` and returns the VList directly,
bypassing `FormatParagraph` entirely.

## Run

```
glu svg-in-table.html
```

(produces `svg-in-table.pdf`.)

## What is **not** fixed by this hook

htmlbag's table layout does not currently honour `<col width="…">` or
`<table style="width: …">` as cell-width constraints — cells stretch
to fill the container regardless. That is a separate upstream issue.
The DeferredSizer hook sizes the SVG against whatever cell width the
layout produces, which is the correct behaviour: when the layout
issue is addressed, the SVGs will automatically adapt.
