# Highlighting text

A draft marked up with a highlighter and a red pen, in plain Markdown:
the marks are bracketed spans with a class, `[text]{.mark}`, and
strikethrough is `~~text~~`. The colors and lines come from
`highlighting.css`.

![first page of result.pdf](firstpage.png)

| Class or element | What to look at |
| ---------------- | --------------- |
| `.mark`, `.green` | `background-color` on an inline element: one band per line that also covers the spaces and reaches from the ascent to the descent of the span's font. A code span inside sits in the same band. |
| `del` | `~~text~~` becomes `<del>`, struck through by default; the stylesheet only colors the line. |
| `.ins` | Text and underline in green. |
| `.spell` | `text-decoration: underline wavy` in red. |
| `.query` | A dotted underline that stops at the end of the text on each line. |

## Run

```bash
glu highlighting.md -o out.pdf
```

The how-to on [boxesandglue.dev](https://boxesandglue.dev/glu/howto/highlighting/)
walks through it step by step.
