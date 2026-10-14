# COLR / CPAL color emoji

Shows COLRv0 color emoji at three sizes. Each base emoji glyph in
Twemoji.Mozilla consists of several layer glyphs. The PDF output paints
each layer in its own CPAL color, all layers at the same baseline
origin.

## What is exercised

| Mechanism                          | What it means                                  |
| ---------------------------------- | ---------------------------------------------- |
| COLRv0 base glyph and layer lookup | Each emoji is looked up in the COLR table and expanded into its layers |
| CPAL palette lookup                | Each layer gets its color from the first CPAL palette |
| Per-layer PDF output               | The layers are drawn on top of each other at the glyph origin |
| Layer glyphs in the font subset    | The embedded subset keeps the outlines of all layers of the emoji used |

Twemoji.Mozilla is included as the test font (from
https://github.com/mozilla/twemoji-colr, Apache 2.0). It carries 3689
base emoji glyphs that expand into 33179 layer glyphs in total, about
9 layers per emoji, over a single CPAL palette with 1063 colors.

## Limits / open ends

- **COLRv1** (paint trees with gradients, transforms, compositing) is
  detected but not rendered. Glyphs with only v1 data fall back to the
  plain `glyf` outline (monochrome).
- **`ForegroundColorIndex` (0xFFFF)** layers, which mean "use the
  current text color", are painted black. boxes and glue does not track
  the text fill color per glyph yet.

Bitmap emoji fonts (CBDT/CBLC and sbix) and SVG-in-OpenType fonts are
supported as well. [`../color-emoji-cbdt`](../color-emoji-cbdt) shows
a CBDT font.

## How to regenerate

```bash
glu color-emoji.html -o out.pdf
```

This produces `out.pdf` (about 20 KB; the font subset carries only the
emoji used in this document and their layer outlines).
