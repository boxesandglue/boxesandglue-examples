# Inline SVG with percentage width

An inline `<svg>` with `width="100%"` is sized against the real width
of its container when the page is laid out, not against a fixed page
width when the HTML is read. The same SVG markup placed in containers
of different widths ends up at different rendered widths.

## What is exercised

| Block        | Container                                                          |
| ------------ | ------------------------------------------------------------------ |
| Container A  | Page-wide block with `padding-left: 30pt` and `padding-right: 30pt` |
| Container B  | Narrower block (`width: 180pt`) with `padding-left: 12pt` and `padding-right: 12pt` |
| Container C  | Reference: SVG with an absolute `width="160pt"`, fixed when the HTML is read |
| Container D  | Inline SVG with `width="100%"` and a dashed line (`stroke-dasharray="6 3"`) |

Container B has an absolute width (`width: 180pt`) to show that the
same `<svg width="100%">` markup adapts to a narrower box. A
percentage width on the block, such as `width: 50%`, works as well.

Containers A and B use the same
`<svg width="100%" viewBox="0 0 100 30">...</svg>` markup; only the
container differs.

## Run

```
glu inline-svg-percentage.html -o out.pdf
```

This produces `out.pdf`. The directory ships a copy as `result.pdf`
and a rendered preview as `firstpage.png`.

## Why this matters

A percentage width only makes sense against the box the SVG ends up
in. Sizing it against the page width would make it too wide inside
narrower blocks or table cells. Because htmlbag waits until the
container width is known, the same SVG fits a padded block, a narrow
block and a table cell (see [`../svg-in-table/`](../svg-in-table/)).
Raster images with a percentage width work the same way (see
[`../img-percentage/`](../img-percentage/)).
