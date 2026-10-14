# Slides Example

This example demonstrates how to create PDF presentation slides with [glu](https://boxesandglue.dev/glu/) using Markdown, Lua, and CSS.

![Preview of the first four slides](slides-preview.png)

## Prerequisites

Install glu using one of these methods:

**Homebrew** (macOS / Linux):

```
brew install boxesandglue/tap/glu
```

**Pre-built binaries** (no Go required):

Download the latest release from <https://github.com/boxesandglue/glu/releases/latest>.

**Build from source** (requires Go):

```
git clone https://github.com/boxesandglue/glu
cd glu
rake build
```

This builds `bin/glu`.

See <https://boxesandglue.dev/glu/> for full installation instructions.

## Running

```
glu slides.md -o out.pdf
```

This writes `out.pdf` (this directory ships a copy as `result.pdf`).

## Files

| File | Purpose |
|------|---------|
| `slides.md` | Slide content in Markdown with YAML frontmatter and embedded Lua blocks |
| `slides.lua` | Companion Lua file: draws decorative accent lines on each content slide using the [hobby](https://boxesandglue.dev/hobby/) curve library |
| `slides.css` | Slide layout: 16:9 page size, `break-before: always` on `h2` for automatic slide breaks, title slide styling |
| `markdown-pipeline.svg` | Diagram shown on one of the slides |

## How it works

- Each `## heading` starts a new slide (via CSS `break-before: always`).
- Lua code blocks (`` ```{lua} ``) are executed during Markdown processing. Use `return` to insert the result into the document.
- Inline expressions `{= expr =}` are replaced with their Lua result.
- The companion file `slides.lua` is loaded automatically and registers a `page_init` callback that draws randomized accent lines at the top and bottom of each content slide. The random seed is fixed, so every run produces the same PDF.
- Setting `format: PDF/UA` in the frontmatter produces a tagged, accessible PDF.
