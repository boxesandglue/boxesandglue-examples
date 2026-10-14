# Inline image alignment via CSS `vertical-align`

Mixed inline content (text and a raster image) in a single paragraph.
The same `<img>` appears in three paragraphs that differ only in their
`vertical-align`:

| `vertical-align`         | Effect on the image                                |
| ------------------------ | -------------------------------------------------- |
| `baseline` (default)     | Image bottom on the text baseline; the image extends upward. |
| `text-top`               | Image top at the ascent of the parent font; the image dips below the baseline. |
| `top`                    | Treated like `text-top`. htmlbag has no real line-box model, so the line-box semantics of `top` fall back to `text-top` for inline images. |

## How it works

An image, like a glyph or a box, has a height above the baseline and
a depth below it. By default the depth is 0, so the image sits on the
baseline (CSS `baseline`).

For `vertical-align: text-top`, htmlbag splits the visible height of
the image:

```
ascent ≈ font-size × 0.8             // typical typoAscender ratio
height = ascent                      // extent above the baseline
depth  = visual height - ascent      // extent below the baseline
```

The image is then drawn with its bottom at the depth below the
baseline. With a depth of 0 this is the same as the baseline
placement.

The ascent ratio of 0.8 is a deliberate approximation. Real fonts
have a typoAscender of roughly 0.75 to 0.82 of the em. Reading the
actual value from the font at this point would cost more than it
gains: for typical inline images the visual difference is below a
pixel.

## Scope

The split applies to raster images with an absolute width or no
width (`<img src="....png">`). Two cases are left unchanged:

- **SVG images** (`<img src="....svg">`) are placed as a box that is
  anchored differently. When the SVG is the tallest item on the line,
  the result is close to `vertical-align: top`; when taller content
  shares the line, it differs from `text-top`.
- **Raster images with a percentage width** (`<img src="....png"
  width="50%">`) are sized later, when the container width is known,
  and are placed the same way as SVG images.

Giving these two cases full `text-top` support would change how other
boxes inside a line are placed, so it is left for a separate change.

## Run

```
glu inline-image-align.html -o out.pdf
```

This produces `out.pdf`. The directory ships a copy as `result.pdf`
and a rendered preview as `firstpage.png`.

## Result

![first page of result.pdf](firstpage.png)
