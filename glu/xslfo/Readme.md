# XSL-FO examples

Four XSL-FO inputs and the Lua walker that turns them into HTML for
htmlbag to render. The walker is a proof-of-concept, not a full XSL-FO
processor — it covers the most common formatting objects and degrades
gracefully on the rest.

## Files

| File | Demonstrates |
|---|---|
| `foproc.lua` | The XSL-FO → HTML walker. Maps `fo:simple-page-master`, `fo:flow`, `fo:block`, `fo:inline`, `fo:footnote`, `fo:float`, and `fo:external-graphic` to their htmlbag equivalents. |
| `01-basic.fo` | Page master, blocks, inline markup (bold/italic/colour), and two footnotes. |
| `02-float-top.fo` | A `fo:float float="before"` carrying multi-block content (caption + supporting block). |
| `03-float-bottom.fo` | A `fo:float float="after"` anchored above the footnote zone. |
| `04-float-mixed.fo` | Top-float + bottom-float + footnote on a single page — the four-layer case htmlbag's two-pass page assembler is built for. |

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

Compound properties (e.g. `space-before.optimum`) are not unpacked;
the walker translates the simple property name to the closest CSS
equivalent.

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
