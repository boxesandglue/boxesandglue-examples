# `<img>` with percentage width

A raster `<img>` with a percentage width adapts to its container in
the same way as an inline `<svg width="100%">` (see
[`../inline-svg-percentage/`](../inline-svg-percentage/)).

## What is exercised

| Block        | Image attribute     | Container                                     |
| ------------ | ------------------- | --------------------------------------------- |
| Container A  | `width="100%"`      | Block with `padding-left:30pt; padding-right:30pt` |
| Container B  | `width="100%"`      | Block with `padding-left:90pt; padding-right:90pt` (much narrower) |
| Container C  | `width="120pt"`     | Fixed width; aspect ratio preserved           |
| Container D  | `width="50%"`       | Plain paragraph at page content width         |

The image `stripe.png` is a 200×100 PNG (blue top half, orange bottom
half). The 2:1 aspect ratio makes the scaling easy to see.

## Why this matters

htmlbag reads a percentage in the `width` attribute of an `<img>` and
waits until the width of the container is known. It then scales the
image to that percentage of the container's content width and keeps
the aspect ratio, unless an explicit `height` is given.

## Run

```
glu img-percentage.html -o out.pdf
```

This produces `out.pdf`. The directory ships a copy as `result.pdf`
and a rendered preview as `firstpage.png`.
