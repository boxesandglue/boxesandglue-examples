# XSL-FO examples

Ten XSL-FO inputs and the Lua walker that turns them into HTML for
htmlbag to render. The walker is a proof-of-concept, not a full XSL-FO
processor — it covers the most common formatting objects and degrades
gracefully on the rest.

## Files

| File | Demonstrates |
|---|---|
| `foproc.lua` | The XSL-FO → HTML walker. Maps `fo:simple-page-master`, `fo:flow`, `fo:block` (with `role="H1..H6"`), `fo:inline`, `fo:footnote`, `fo:float`, `fo:external-graphic` (with `alt=`), `fo:declarations/bg:font-face` (extension namespace), `xml:lang`/`language`, `hyphenate`, plus document-level `bg:format` and `fo:title` for PDF/UA. |
| `01-basic.fo` | Page master, blocks, inline markup (bold/italic/colour), and two footnotes. |
| `02-float-top.fo` | A `fo:float float="before"` carrying multi-block content (caption + supporting block). |
| `03-float-bottom.fo` | A `fo:float float="after"` anchored above the footnote zone. |
| `04-float-mixed.fo` | Top-float + bottom-float + footnote on a single page — the four-layer case htmlbag's two-pass page assembler is built for. |
| `05-image.fo` | `fo:external-graphic` referencing the bundled `ocean.pdf` from inside a flow block. |
| `06-image-float.fo` | Image plus caption inside a `fo:float float="before"` — the figure-at-top-of-page pattern. |
| `07-rtl-arabic.fo` | Arabic-only blocks set in Amiri (registered via `fo:declarations/bg:font-face`) — automatic RTL reordering and Arabic shaping. |
| `08-mixed-ltr-rtl.fo` | English and Arabic in the same paragraph with per-run `xml:lang` — bidi reordering plus per-language hyphenation. |
| `09-soft-hyphen.fo` | CSS Text 3 `hyphens` modes (`auto`/`manual`/`none`) controlled by the `hyphenate` FO property, with U+00AD soft-hyphens steering the line breaker. |
| `10-pdfua.fo` | PDF/UA (ISO 14289-1) accessibility showcase — `bg:format="PDF/UA"` enables htmlbag's tagged-PDF pipeline. `<fo:title>` populates `/Title`, `xml:lang` populates `/Lang`, `role="H1..H6"` produces heading structure elements, `alt=` on `fo:external-graphic` populates the Figure `/Alt` entry. |

## Bundled assets

| File | Source / licence |
|---|---|
| `ocean.pdf` | Copy of the same image used by `baseline/image/`. |
| `amiri-regular.ttf` | Amiri Regular (SIL Open Font Licence 1.1, see `amiri.license`). |
| `amiri-slanted.ttf` | Amiri Slanted — used as the italic variant of the Amiri family. |

## Workflow

A single `glu` invocation walks the FO, builds HTML in memory, and
hands it to glu's HTML pipeline:

```bash
glu foproc.lua 01-basic.fo            # writes 01-basic.pdf
```

The intermediate HTML is built in memory; no `.html` file is left on
disk. To inspect or debug the generated HTML, append the `keep-html`
keyword:

```bash
glu foproc.lua 01-basic.fo keep-html  # writes 01-basic.pdf and 01-basic.html
```

(The marker is a positional keyword rather than a `--flag` because
glu reserves `--html` for its own debug-output flag and swallows it
before the script sees it.)

## What's covered

| XSL-FO feature | Mapping |
|---|---|
| `fo:simple-page-master` | `@page { size, margin }` |
| `fo:flow` | `<body>` |
| `fo:block` | `<p style="...">` |
| `fo:inline` | `<span style="...">` |
| `fo:footnote` / `fo:footnote-body` | `<fn>...</fn>` |
| `fo:float[@float="before"]` | `<div style="float: top">` |
| `fo:float[@float="after"]` | `<div style="float: bottom">` |
| `fo:external-graphic` | `<img>` |
| `fo:declarations/bg:font-face` | `@font-face { font-family; src; font-weight; font-style }` |
| `xml:lang="en"` | `lang="en"` |
| `language="en" country="US"` | `lang="en-US"` (BCP47 composite) |
| `hyphenate="true|false"` | `hyphens: auto|none` |

Compound properties (e.g. `space-before.optimum`) are not unpacked;
the walker translates the simple property name to the closest CSS
equivalent.

`bg:font-face` lives in our own extension namespace
`https://boxesandglue.dev/ns/xslfo`, declared on `fo:root` as
`xmlns:bg="…"`. XSL-FO 1.1 §6.4.2 explicitly allows elements from any
other namespace inside `fo:declarations`, which is why this passes
schema validation in oxygen XML and similar tools (where `fo:font-face`
would not — it is not on the spec's element list). The shape mirrors
CSS `@font-face` so the walker can pass it through verbatim.

## Right-to-left text

htmlbag does not honour `dir="rtl"` or CSS `direction`. RTL is enabled
automatically when boxesandglue's paragraph builder sees Arabic /
Hebrew codepoints — bidi reordering and Arabic shaping run as a side
effect of running the line breaker on the content. The .fo files in
07/08 therefore just embed UTF-8 Arabic; no extra direction property
is required.

## Per-run hyphenation

The walker maps `xml:lang` (and the `language`+`country` pair) to HTML
`lang=`. htmlbag resolves the tag to a TeX hyphenation pattern set and
hands it to the typesetter as a per-run language switch. Tags without
a TeX pattern (Arabic, Hebrew, CJK, …) resolve to a no-op hyphenator,
matching CSS Text 3 §6 — a UA must not hyphenate without matching
patterns.

The `hyphenate` FO property maps to CSS `hyphens`:

* `hyphenate="true"`  → `hyphens: auto`   — automatic + soft-hyphens
* `hyphenate="false"` → `hyphens: none`   — never break
* `hyphenate="manual"` → `hyphens: manual` — only `&#xAD;` (U+00AD)

A soft-hyphen embedded in the text (`&#xAD;`, the XML numeric
character reference for U+00AD) is preserved end-to-end and produces
a discretionary break point at that position whenever `hyphens` is
not `none`. Example 09 demonstrates the three modes side by side.

## PDF/UA tagging

Set `bg:format="PDF/UA"` on `fo:root` to opt the document into the tagged-PDF
pipeline. The walker reads three top-level metadata items:

| Source | Effect |
|---|---|
| `xml:lang` on `fo:root` | PDF `/Lang` catalog entry, document-wide hyphenation default |
| `bg:format="PDF/UA"` on `fo:root` | Enables `MarkInfo /Marked true`, `StructTreeRoot`, `/DisplayDocTitle`, XMP `pdfuaid:part 1`, per-element role mapping |
| `<fo:title>` (child of `fo:root`) | PDF `/Title` (also XMP `dc:title`) |

Inside the flow:

| Source | Structure element |
|---|---|
| `<fo:block role="H1">` … `role="H6"` | `H1` … `H6` |
| `<fo:block>` | `P` |
| `<fo:external-graphic alt="…">` | `Figure` with `/Alt` entry |
| `<fo:inline>` | `Span` |

Verify with `pdfinfo` (Title, Tagged: yes, Lang) and `veraPDF --profile PDF/UA-1`
for full ISO 14289-1 conformance. Example 10 covers all of the above.

## What's not covered

The walker deliberately ignores anything that the underlying htmlbag
layout engine doesn't support: side floats (`float="start"|"end"|
"inside"|"outside"`), `fo:marker` / `fo:retrieve-marker` (running
content), `fo:repeatable-page-master-alternatives` (left/right page
asymmetry), `fo:page-number-citation`, multi-column regions. Inputs
using these elements will pass through partially or be silently
dropped.

For the htmlbag-side documentation of what's supported, see the
[htmlbag handbook section](https://doc.speedata.de/htmlbag/) (or the
local `boxesandglue-website/content/htmlbag/` source).
