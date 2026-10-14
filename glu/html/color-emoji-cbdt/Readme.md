# CBDT color bitmap

Shows glyphs from a font in Google's CBDT/CBLC color bitmap format.
CBDT stores one PNG per glyph and strike in its data table, and CBLC
indexes them by strike and glyph. The engine picks the strike that
fits the font size best and embeds the PNG as a PDF image XObject.

## What is exercised

| Mechanism                                       | What it means                                  |
| ----------------------------------------------- | ---------------------------------------------- |
| CBLC parsing with IndexSubtable formats 1 and 3 | The glyph's PNG is found through the CBLC index (this font uses format 1) |
| Image formats 17, 18 and 19                     | All three CBDT image formats are read (this font uses format 17) |
| Best-fit strike selection                       | The strike is chosen per font size as HarfBuzz does; this font has a single 109 ppem strike, used at 14pt, 36pt and 72pt |
| PDF image XObject output                        | Each bitmap glyph is placed as an image in the glyph cell |
| Image cache per font, glyph and size            | A glyph repeated at the same size embeds its PNG only once |

## Bundled font

`NotoColorEmoji.subset.ttf` is included (SIL OFL 1.1). It is a subset
from HarfBuzz's fuzzing corpus and carries only five glyphs: '8', '9',
'®', '⁉' and the keycap combiner '⃣'. That is enough to verify the
pipeline, not enough for a full emoji showcase.

## Limits / open ends

- xOffset and yOffset in the glyph metrics are ignored; bitmaps are
  drawn at the nominal glyph cell.
- Strike selection follows the HarfBuzz rule (the smallest strike at
  least as large as the font size) rather than always picking the
  largest strike, which would be ideal for PDF.
- Only IndexSubtable formats 1 and 3 are decoded, the same scope as the
  HarfBuzz CBDT subsetter. Formats 2, 4 and 5 are not used by Noto Color
  Emoji.

## How to regenerate

```bash
glu color-emoji-cbdt.html -o out.pdf
```
