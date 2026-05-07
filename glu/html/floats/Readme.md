# Floats / Inserts

Five examples for `htmlbag`'s float and footnote system. Each example
lives in its own subdirectory with a `result.pdf` and a
`firstpage.png` next to the source `.html`.

## Examples

Description | Preview
--- | ---
[01 — Inline top float](01-inline-top) — `<span style="float: top">` lifts inline content to the top stack | <a href="01-inline-top"><img src="01-inline-top/firstpage.png" width="200"></a>
[02 — Inline bottom float](02-inline-bottom) — `<span style="float: bottom">` lands the run above the footnote zone | <a href="02-inline-bottom"><img src="02-inline-bottom/firstpage.png" width="200"></a>
[03 — Block float, multiple paragraphs](03-block-multi-paragraph) — `<div style="float: top">` for block-level content | <a href="03-block-multi-paragraph"><img src="03-block-multi-paragraph/firstpage.png" width="200"></a>
[04 — All four insert classes](04-mixed-classes) — top-float + body + bottom-float + footnote on one page | <a href="04-mixed-classes"><img src="04-mixed-classes/firstpage.png" width="200"></a>
[05 — Three floats sharing one page](05-three-floats-one-page) — two-pass page assembly with multiple top-floats | <a href="05-three-floats-one-page"><img src="05-three-floats-one-page/firstpage.png" width="200"></a>

## Float syntax

Floats are detected via the CSS `float` property — recognised values:

* `top` / `before`    → top-of-page stack (XSL-FO `fo:float float="before"`)
* `bottom` / `after`  → bottom-of-page stack, above any footnotes

Use a `<span>` for inline content that should be lifted to a page edge
(text, inline markup, inline images). Use a `<div>` when the float
needs to carry block-level content (multiple paragraphs, lists, a
caption block). Standard CSS `float: left|right` (side-floats with
text wrap) is not implemented.

## Footnote syntax

Footnotes use the `<fn>` element (or any element with
`class="footnote"`) and stack at the bottom of their page above a
separator rule. Numbering is automatic via the `footnote` counter.

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
