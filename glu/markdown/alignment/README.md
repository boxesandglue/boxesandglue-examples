# Alignment Example

This example demonstrates paragraph alignment in glu's Markdown
pipeline using the `{.class}` attribute syntax. Headings get a class,
an external stylesheet maps the class to `text-align`, and the
boxesandglue-specific `-bag-linebreak-*` properties tune the
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
glu simple.md -o out.pdf
```

This writes `out.pdf` (this directory ships a copy as `result.pdf`).

## Files

| File | Purpose |
|------|---------|
| `simple.md` | Markdown source: the frontmatter selects German hyphenation patterns and the stylesheet, the body uses `# Heading {.right}` and similar |
| `simple.css` | Utility classes for alignment, an adjacent-sibling rule that carries the heading class to the following paragraph, and `-bag-linebreak-*` tuning |

## Heading attributes

glu reads a `{.class}` suffix on a heading and turns it into an HTML
class:

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

The adjacent-sibling rule `h1.right + p` only catches one paragraph.
A single paragraph can also take a class directly: put `{.center}` on
the line right after it, with no blank line in between. For a run of
paragraphs, wrap the section in a `<div>`. glu passes inline HTML
through, as this example shows:

```markdown
<div class="center">

First paragraph …

Second paragraph …

</div>
```

A fenced div (`::: {.center}` … `:::`) produces the same `<div>`
without HTML.

## Hyphenation tuning

The Knuth-Plass line breaker is conservative by default
(tolerance 4, hyphen penalty 50). On long German compound words
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
| `-bag-linebreak-tolerance` | float | The largest adjustment ratio a line may have, default 4. Higher values accept looser lines. It is a ratio, not a badness like TeX's `\tolerance`: TeX's 200 corresponds to about 1.26. |
| `-bag-linebreak-hyphen-penalty` | int | Penalty added to demerits at a hyphenation point (TeX `\hyphenpenalty`). Lower values mean more hyphenation. |

The value 200 in this example therefore puts practically no limit on
how far the spaces may stretch.

The hyphenation patterns themselves come from the frontmatter `lang:`
key:

```yaml
---
lang: de
---
```

This loads the German TeX hyphenation patterns. Language tags without
patterns (Arabic, Hebrew, CJK and others) get no hyphenation.

See the [glu documentation](https://boxesandglue.dev/glu/markdown/) and
the [htmlbag CSS reference](https://boxesandglue.dev/htmlbag/css-properties/)
for the full attribute and property catalog.
