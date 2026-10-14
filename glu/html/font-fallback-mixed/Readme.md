# Per-glyph CSS font fallback

Shows the prioritized font list of CSS Fonts 4 §3.1, resolved for each
grapheme cluster. A single `font-family: A, B, C` stack on the body
covers paragraphs that mix Latin text, color emoji and Arabic. No
`<span>` wrappers are needed for the different scripts.

```css
body {
    font-family: sans-serif, "Twemoji", "Amiri";
}
```

Three paragraphs exercise the matching:

| Paragraph                                | Which family sets what |
| ---------------------------------------- | ---------------------- |
| `🟢 live, 🟡 staging, 🔴 down.`             | sans-serif for the Latin runs, Twemoji for the three colored circles |
| `Trinkgeld 💶 dankend abgelehnt.`           | sans-serif for the German text, Twemoji for `💶` (U+1F4B6) |
| `السلام عليكم 🌍 hello world.` (`dir="rtl"`) | Amiri for the Arabic, Twemoji for `🌍`, sans-serif for the trailing Latin run |

In the right-to-left paragraph the bidi reordering works together with
the fallback: the Latin, Arabic and emoji runs each get the right
family, and the visual order still follows the Unicode bidirectional
algorithm.

## How it works

boxes and glue splits the text of each paragraph into UAX #29 grapheme
clusters (with the `clipperhouse/uax29` segmenter) and probes the
font-family stack from left to right for each cluster:

1. Try the first declared family. If its font has a glyph for every
   code point in the cluster, use it.
2. Otherwise move on to the next family in the stack and repeat.
3. The cluster is shaped with the first family that matches. Adjacent
   clusters that resolve to the same family are joined into a single
   shaping run, so kerning and ligatures across them still work.

Spaces always use the first family, so the word spaces keep its
metrics. The coverage probe results are cached per font and code point,
so a repeated probe costs one map lookup instead of a fresh cmap
traversal.

The fallback runs **before** shaping, which is the order CSS Fonts 4
describes and browsers implement. Doing it after shaping would leave
tofu glyphs for every code point the first font lacks, since shaping
itself does no fallback.

## Bundled fonts

| Font                          | License                                   | Coverage in this example |
| ----------------------------- | ----------------------------------------- | ------------------------ |
| `Twemoji.Mozilla.ttf`         | Apache 2.0 (from mozilla/twemoji-colr)    | Color emoji via COLR/CPAL |
| `amiri-regular.ttf`           | SIL OFL 1.1 (`amiri.license` included)    | Arabic text |
| `sans-serif`                  | built into htmlbag (TeX Gyre Heros)       | Latin text |

The `sans-serif` family is one of the fonts that come with htmlbag, so
no font file is shipped for it.

## Run

```bash
glu font-fallback-mixed.html -o out.pdf
```

This produces `out.pdf`. The checked-in `result.pdf` was generated with
`SOURCE_DATE_EPOCH=0 glu font-fallback-mixed.html -o out.pdf`, so its
bytes are reproducible. `firstpage.png` is a preview of it.

## What's exercised

| Mechanism                                    | Where to see it                                                |
| -------------------------------------------- | -------------------------------------------------------------- |
| UAX #29 grapheme segmentation                | every paragraph                                                |
| Per-cluster probe of the prioritized list    | the emoji between Latin words                                  |
| Coverage cache per font                      | speed only, not visible in the PDF                             |
| Joining adjacent clusters of the same family | the Latin runs, shaped as whole words                          |
| COLR/CPAL emoji output                       | the emoji; see also [`../color-emoji`](../color-emoji)         |
| Bidi reordering together with font fallback  | the RTL paragraph                                              |
