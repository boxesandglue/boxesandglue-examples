# Lua interface examples

Programmatic use of glu's Lua bindings — the API is called directly
from a `.lua` script, no Markdown / HTML pipeline in front. Useful
when you need full control over the document construction (custom
page layout, programmatic text generation, structured data → PDF
binding, …).

## Examples

Description | Preview
--- | ---
[Text shaping](textshape) — `frontend.shape` glyph dump (console output, no PDF). Demonstrates how to drive the shaper directly and inspect cluster, advance and codepoint mapping. | <code>glyph=362 cluster=0 …</code>
[ZUGFeRD invoice](zugferdinvoice) — EN 16931 / ZUGFeRD 2.x electronic invoice as a PDF/A-3 with embedded Cross-Industry-Invoice XML attachment. | <a href="zugferdinvoice"><img src="zugferdinvoice/firstpage.png" width="200"></a>

## Workflow

```bash
glu <name>.lua
```

If a script accepts arguments, they're forwarded positionally after
the script name:

```bash
glu zugferdinvoice/render.lua --customer Mustermann --due 2026-06-30
```

(glu-owned flags like `--loglevel` or `--css` are parsed off the
front before the script sees its arguments.)

## What the Lua API covers

The bindings that glu exposes (registered in `glu/main.go`):

| Module | Purpose |
|---|---|
| `glu` | Top-level: `glu.frontend.*`, `glu.node.*`, `glu.font.*` |
| `glu.frontend` | High-level document/page/text API — paragraphs, tables, fonts, hyperlinks |
| `glu.node` | Low-level node manipulation — Glyph, HList, VList, Glue, Kern, Rule |
| `glu.font` | Font loading and face selection |
| `glu.pdf` | Low-level PDF writer (raw operators, annotations, font subsetting) |
| `glu.htmlbag` | One-shot `render(html, out.pdf [, opts])` — drop a chunk of HTML into the current document |
| `glu.textshape` | Direct shaper access (HarfBuzz-style glyph clusters) |
| `glu.json` | JSON encode / decode |
| `glu.log` | Structured logging hooked into glu's log destination |
| `xml.cxpath` | XPath queries against an XML tree (used heavily in `zugferdinvoice` for the XML → PDF binding) |
| `hobby` | MetaPost-style curve solver (from the external `hobby` module) |

LuaCATS type definitions are available under `glu/types/`; pointing a
Lua language server at that directory gives autocomplete and hover
docs.

## Lifecycle callbacks

Register handlers via `glu.frontend.add_callback(event, fn)`. The
events fired by the pipeline are documented in
`bag/glu/CLAUDE.md`; the short list is `document_start`,
`content_ready`, `pre_shipout`, `page_init`, `post_element`,
`document_end`.

## Aux file

Markdown / HTML inputs maintain a `<input>-aux.json` companion file
for cross-references, TOCs, and any state Lua wants to persist across
the multi-pass convergence loop. For pure Lua entrypoints, the aux
roundtrip is the script's responsibility — see the ZUGFeRD example
for one way to handle it.

For the full glu Lua-API reference, see the
[glu handbook](https://boxesandglue.dev/glu/) (or the local
`boxesandglue-website/content/glu/` source).
