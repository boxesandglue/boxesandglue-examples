# COLR / CPAL color emoji

Demonstrates COLRv0 color emoji rendering. Each base emoji glyph in
Twemoji.Mozilla decomposes into multiple layer glyphs; the PDF emitter
paints each layer in its own CPAL color, overlaid at the same baseline
origin.

## What is exercised

| Mechanism                          | Source                                         |
| ---------------------------------- | ---------------------------------------------- |
| COLRv0 base-glyph / layer parsing  | `textshape/ot/colr.go` (`COLR.GlyphLayers`)    |
| CPAL palette lookup                | `textshape/ot/cpal.go` (`CPAL.PaletteColors`)  |
| Per-layer PDF emission             | `boxesandglue/backend/document/document.go` (`emitColorGlyph`) |
| Layer-GID subset registration      | same — `face.RegisterGlyph(layer.GlyphID, "")` |

Twemoji.Mozilla is included as the test font (vendored from
https://github.com/mozilla/twemoji-colr, Apache 2.0). It carries
3689 base emoji glyphs that expand into 33179 layer glyphs total —
average ~9 layers per emoji — over a single 1063-color CPAL palette.

## Limits / open ends

- **COLRv1** (paint trees with gradients, transforms, compositing) is
  detected by `COLR.HasV1Data` but not rendered. Glyphs with only v1
  data fall through to the plain `glyf` outline (monochrome).
- **`SVG `**-in-OpenType is not supported. Fonts that store color as
  SVG subtrees (e.g. Adobe-style color emoji, the `TwitterEmoji.ttf`
  in the print-css-rocks `lesson-fonts-emoji`) render monochrome.
- **CBDT/sbix** bitmap emoji fonts: not implemented.
- **`ForegroundColorIndex` (0xFFFF)** layers — meaning "use the current
  text foreground" — fall back to black; boxesandglue does not yet
  track text fill color per glyph.

## How to regenerate

```bash
glu color-emoji.html
```

Produces `color-emoji.pdf` (~20 KB; subset font carries only the
emojis used in this document plus their layer outlines).
