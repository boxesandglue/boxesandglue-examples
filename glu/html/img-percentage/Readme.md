# `<img>` with percentage width

Exercises the DeferredSizer protocol's second concrete implementation:
`rasterImageDeferred`. The same generalisation that lets inline `<svg
width="100%">` adapt to its container now also handles raster
`<img width="100%">`.

## What is exercised

| Block        | Image attribute     | Container                                     |
| ------------ | ------------------- | --------------------------------------------- |
| Container A  | `width="100%"`      | Block with `padding-left:30pt; padding-right:30pt` |
| Container B  | `width="100%"`      | Block with `padding-left:90pt; padding-right:90pt` (much narrower) |
| Container C  | `width="120pt"`     | Eager path (no sizer); aspect ratio preserved |
| Container D  | `width="50%"`       | Plain paragraph at page content width         |

The fixture `stripe.png` is a 200×100 PNG (blue top half, orange bottom
half). The 2:1 aspect ratio makes the rescaling visible by eye.

## Why this matters

Before this patch, `<img width="100%">` in htmlbag panicked at
`bag.MustSP("100%")` — the percent suffix was unsupported by the SP
parser. The percent path now goes through `parseSVGPercentWidth`, which
recognises the suffix and routes to a `rasterImageDeferred` sizer
attached to a wrapper VList. The shared walker
`resolveDeferredSizing` in `vlistbuilder.go`'s leaf branch invokes
`Materialize(containerWidth, df)` once the contentWidth is final; the
sizer rescales the underlying `*node.Image` in place, preserving aspect
ratio unless an explicit `height` was given.

## Run

```
glu img-percentage.html
```

(produces `img-percentage.pdf`.)
