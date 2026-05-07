# Alignment Example

This example demonstrates paragraph alignment in glu's Markdown
pipeline using the goldmark `{.class}` attribute syntax. Headings
get a class, an external stylesheet maps the class to `text-align`,
and the boxesandglue-specific `-bag-linebreak-*` properties tune the
Knuth-Plass line breaker so long German compound words hyphenate
instead of overflowing the right margin.

![first page of result.pdf](firstpage.png)

## Prerequisites

Install glu using one of these methods:

**Homebrew** (macOS / Linux):

```
brew install boxesandglue/tap/glu
```

**Pre-built binaries** (no Go required):

Download the latest release from <https://github.com/boxesandglue/glu/releases/latest>.

See <https://boxesandglue.dev/glu/> for full installation instructions.

## Running

```
glu simple.md
```

This produces `simple.pdf` (this directory ships a copy as `result.pdf`).

## Files

| File | Purpose |
|------|---------|
| `simple.md` | Markdown source — front matter selects German hyphenation patterns and the stylesheet, body uses `# Heading {.right}` etc. |
| `simple.css` | Utility classes for alignment, an adjacent-sibling rule that carries the heading class to the following paragraph, and `-bag-linebreak-*` tuning |

## Heading attributes

goldmark's `parser.WithAttribute()` (enabled in glu) parses a
`{.class}` suffix on a heading and turns it into an HTML class:

| Markdown | HTML output |
|----------|-------------|
| `# Right aligned {.right}` | `<h1 class="right">Right aligned</h1>` |
| `# Justified {.justify}` | `<h1 class="justify">Justified</h1>` |
| `# Centered {.center}` | `<h1 class="center">Centered</h1>` |

The CSS rule `.right { text-align: right }` aligns the heading; the
adjacent-sibling rule `h1.right + p { text-align: right }` carries
the alignment to the directly following paragraph without a
wrapping `<div>`.

## Multi-paragraph alignment

Goldmark only attaches attributes to headings, not to paragraphs, and
the adjacent-sibling rule `h1.right + p` only catches one paragraph.
For a run of paragraphs, wrap the section in inline HTML — Markdown's
unsafe renderer (also enabled in glu) passes it through:

```markdown
<div class="center">

First paragraph …

Second paragraph …

</div>
```

## Hyphenation tuning

The Knuth-Plass line breaker is conservative by default
(`Tolerance=4`, `Hyphenpenalty=50`). On long German compound words
like *Geschwindigkeitsbegrenzungen* this can prefer a slightly
overfull line to a hyphenated one. The two boxesandglue-specific
CSS properties relax that:

```css
body {
	-bag-linebreak-tolerance: 200;
	-bag-linebreak-hyphen-penalty: 5;
}
```

| Property | Type | Effect |
|----------|------|--------|
| `-bag-linebreak-tolerance` | float | Knuth-Plass badness ceiling (TeX `\tolerance`). Higher = looser lines accepted. |
| `-bag-linebreak-hyphen-penalty` | int | Penalty added to demerits at a hyphenation point (TeX `\hyphenpenalty`). Lower = more hyphenation. |

Hyphenation patterns themselves come from the front-matter `lang:` key:

```yaml
---
lang: de
---
```

This loads the German TeX hyphenation patterns; tags without
patterns (Arabic, Hebrew, CJK, …) resolve to a no-op hyphenator.

See the [glu documentation](https://boxesandglue.dev/glu/markdown/) and
the [htmlbag CSS reference](https://boxesandglue.dev/htmlbag/) for the
full attribute and property catalogue.
