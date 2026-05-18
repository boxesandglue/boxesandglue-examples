# Inline SVG with percentage width

Shows the DeferredSizer mechanism: an inline `<svg>` with
`width="100%"` is parsed once and materialised against the real
container width at layout time, rather than being frozen at
`DefaultPageWidth` at parse time. The same SVG markup placed in
three different containers ends up at three different rendered
widths.

## What is exercised

| Block        | Container behaviour                                                |
| ------------ | ------------------------------------------------------------------ |
| Container A  | Page-wide block with `padding-left: 30pt` and `padding-right: 30pt` |
| Container B  | Half-width block (`width: 180pt`) with `padding-left: 12pt` and `padding-right: 12pt` |
| Container C  | Reference: SVG with an absolute `width="160pt"` (eager path, no sizer) |
| Container D  | Inline SVG with `stroke-dasharray="6 3"` to confirm dash patch end-to-end |

Container B uses an absolute width (`width: 180pt`) to demonstrate
that the same `<svg width="100%">` markup adapts to a genuinely
narrower outer box. CSS percentage width (`width: 50%`) is the
natural form, but htmlbag's block layout does not currently
propagate percentage block widths through the page-content
calculation.

The same `<svg width="100%" viewBox="0 0 100 30">…</svg>` markup is
used in containers A and B; only the host container differs.

## Run

```
glu inline-svg-percentage.html
```

(produces `inline-svg-percentage.pdf`.)

## Why this matters

Before this patch, an `<svg width="100%">` inside HTML was either
dropped on the floor (because `<svg>` was not recognised as a leaf
element) or rendered against `DefaultPageWidth` regardless of the
actual container — useless inside narrower blocks or table cells.
The new `DeferredSizer` interface (`htmlbag/deferred_sizing.go`) is
the generic protocol: collectHorizontalNodes attaches an
`inlineSVGDeferred` to the wrapper VList, and the leaf branch of
`buildVlistInternal` invokes `Materialize(containerWidth, df)` when
the contentWidth is final. The protocol is intentionally extensible:
the same mechanism will carry raster images and embedded PDFs at
percentage widths in subsequent commits.
