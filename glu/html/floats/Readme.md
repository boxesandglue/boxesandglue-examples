# Floats / Inserts

Five examples for `htmlbag`'s float and footnote system. All five
produce a single A5/A6 page; run with `glu` and inspect the resulting
PDF.

## Files

| File | Demonstrates |
|---|---|
| `01-inline-top.html` | Inline top-float via `<span style="float: top">` |
| `02-inline-bottom.html` | Inline bottom-float via `<span style="float: bottom">` |
| `03-block-multi-paragraph.html` | Block-level float (`<div style="float: top">`) carrying multiple paragraphs and a caption |
| `04-mixed-classes.html` | All four insert classes coexisting on one page: top-float, body, bottom-float, footnote |
| `05-three-floats-one-page.html` | Three top-floats from three paragraphs sharing one page (two-pass page assembly) |

## Float syntax

Floats are detected via the CSS `float` property — recognised values:

- `top` / `before` → top-of-page stack (XSL-FO `fo:float float="before"`)
- `bottom` / `after` → bottom-of-page stack, above any footnotes

Use a `<span>` for inline content that should be lifted to a page edge
(text, inline markup, inline images). Use a `<div>` when the float
needs to carry block-level content (multiple paragraphs, lists, a
caption block). Standard CSS `float: left|right` (side-floats with
text wrap) is not implemented.

## Footnote syntax

Footnotes use the `<fn>` element (or any element with `class="footnote"`)
and stack at the bottom of their page above a separator rule. Numbering
is automatic via the `footnote` counter.

## Page-painting order

For a given page the painters run in this order — `flushInserts` in
`htmlbag/insert.go`:

```
1. Top-float stack       (yStart, going down)
2. Buffered body         (just below the float zone)
3. Bottom-float stack    (above the footnote zone)
4. Footnote stack        (yLimit, going up; separator rule above)
```

Markers leave no glyph in body text (footnote-marker becomes a
superscript number; float-marker becomes empty).
