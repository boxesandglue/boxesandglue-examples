# CBDT color bitmap

Demonstrates Google/Microsoft's CBDT/CBLC color-bitmap glyph format
rendering. CBDT stores glyph PNGs in the data table, with CBLC indexing
them by (strike, glyph) — slightly more layered than sbix but the same
underlying idea: per-glyph PNGs that the engine picks up by best-fit
PPEM and embeds as PDF Image XObjects.

## What is exercised

| Mechanism                                       | Source                                         |
| ----------------------------------------------- | ---------------------------------------------- |
| CBLC parsing with IndexSubtable Format 1 and 3  | `textshape/ot/cbdt.go` (`ParseCBLC`)           |
| Image format dispatch (17/18/19)                | same — `CBLC.GlyphPNG`                         |
| Best-fit strike selection                       | same — `chooseStrike`, mirroring HB at CBDT.hh:789-813 |
| PDF Image XObject emission                      | `boxesandglue/backend/document/document.go` (`emitColorBitmapGlyph`) |
| Per-(face, gid, ppem) image cache               | same — `colorBitmapCache` in `objectContext`   |

## Bundled font

NotoColorEmoji.subset.ttf is included (SIL OFL 1.1). It is HarfBuzz's
own fuzz-corpus subset and carries only five glyphs: '8', '9', '®', '⁉'
and the keycap combiner '⃣'. Enough to verify the pipeline; not enough
to be a full emoji showcase.

## Limits / open ends

Same caveats as the sbix example:
- xOffset/yOffset on the glyph metrics are ignored; bitmaps render
  at the nominal glyph cell.
- Strike selection follows HB's smallest-at-least rule rather than
  always picking the largest strike (which would be ideal for PDF).
- Only IndexSubtable Formats 1 and 3 are decoded (same scope as HB's
  CBDT subsetter). Formats 2, 4, 5 are not used by NotoColorEmoji
  nor AppleColorEmoji, so this matches the production-relevant subset.

## How to regenerate

```bash
glu color-emoji-cbdt.html
```
