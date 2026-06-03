# Per-glyph CSS font fallback

Demonstrates CSS Fonts 4 §3.1 prioritised-font-list fallback resolved
at grapheme-cluster granularity. A single `font-family: A, B, C` stack
on the body covers a paragraph that mixes Latin text, colour emoji and
Arabic — no per-run `<span>` wrappers needed.

```css
body {
    font-family: sans-serif, "Twemoji", "Amiri";
}
```

Three paragraphs exercise the matching:

| Paragraph                                | Coverage path |
| ---------------------------------------- | ------------- |
| `🟢 live, 🟡 staging, 🔴 down.`             | sans-serif for Latin runs, Twemoji for the three coloured circles |
| `Trinkgeld 💶 dankend abgelehnt.`           | sans-serif for the German text, Twemoji for `💶` (U+1F4B6) |
| `السلام عليكم 🌍 hello world.` (`dir="rtl"`) | Amiri for Arabic, Twemoji for `🌍`, sans-serif for the trailing Latin run |

The bidi reorder in the RTL paragraph composes with the per-glyph
fallback: Latin → Arabic → emoji each pick the right family, and the
visual order still matches the CSS Writing Modes 4 reordering algorithm.

## How it works

htmlbag breaks each paragraph into UAX #29 grapheme clusters (via the
`clipperhouse/uax29` segmenter) and probes the font-family stack from
left to right per cluster:

1. Try the first declared family. If the active face's `cmap` returns
   a non-zero glyph ID for every codepoint in the cluster, use it.
2. Otherwise advance to the next family in the stack and repeat.
3. The cluster is shaped with the first matching family; adjacent
   clusters that resolve to the same family are coalesced into a
   single shaping run so kerning and ligatures across them still work.

A per-`FontSource` cmap cache short-circuits the coverage probe so the
probe cost per cluster is one map lookup, not a fresh cmap traversal.

The fallback runs **before** harfbuzz shaping, which is the order CSS
Fonts 4 prescribes (§3.1, "matching algorithm") and the order browsers
implement. Doing it after shaping would mean tofu glyphs for any
codepoint the first font lacks, since shaping itself produces no
fallback.

## Bundled fonts

| Font                          | License                                   | Coverage in this example |
| ----------------------------- | ----------------------------------------- | ------------------------ |
| `Twemoji.Mozilla.ttf`         | Apache 2.0 (vendored from mozilla/twemoji-colr) | Colour emoji via COLR/CPAL |
| `amiri-regular.ttf`           | SIL OFL 1.1 (`amiri.license` included)    | Arabic text |
| `sans-serif`                  | resolved by glu's default font setup      | Latin text |

sans-serif comes from htmlbag's built-in font registration — no
external file shipped for it.

## Run

```bash
glu font-fallback-mixed.html
```

This produces `font-fallback-mixed.pdf`. The checked-in `result.pdf`
and `firstpage.png` were generated with `SOURCE_DATE_EPOCH=0 glu
font-fallback-mixed.html -o out.pdf` so the bytes are reproducible.

## What's exercised

| Mechanism                                    | Source                                                         |
| -------------------------------------------- | -------------------------------------------------------------- |
| UAX #29 grapheme segmentation                | `boxesandglue/textshape/shape.go` (via clipperhouse/uax29 v2.5.0) |
| Prioritised-list per-cluster cmap probe      | `boxesandglue/frontend/nodebuilding.go` (`shapeWithBidi`)      |
| Per-`FontSource` cmap cache                  | same                                                           |
| Coalescing of adjacent same-family clusters  | same                                                           |
| COLR/CPAL emoji emission                     | see also [`../color-emoji`](../color-emoji)                    |
| BiDi reorder composed with font fallback     | the RTL paragraph                                              |
