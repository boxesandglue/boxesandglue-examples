# TeX math in Markdown

This example writes formulas in TeX dollar syntax inside a Markdown
file. `math: true` in the frontmatter turns it on: inline math goes
between single dollars, display math between double dollars. glu
converts the TeX to MathML and sets it with the same math engine as
the `<math>` element in HTML. With `format: PDF/UA-2` each formula is
tagged as `Formula` and carries its MathML as an associated file. The
[how-to](https://boxesandglue.dev/glu/howto/tex-math/) walks through it
step by step.

![first page of result.pdf](firstpage.png)

## Run

```
glu tex-math.md -o out.pdf
```

This produces `out.pdf` (this directory ships a copy as `result.pdf`).

## Files

| File | Purpose |
|------|---------|
| `tex-math.md` | Markdown source with `math: true` and `format: PDF/UA-2` in the frontmatter |
| `tex-math.css` | Stylesheet: A5 page, `@font-face` for Latin Modern Math and `font-family` on the `math` element |
| `latinmodern-math.otf` | Latin Modern Math, an OpenType font with a MATH table |

## What it shows

- Inline formulas such as `$E=mc^2$`, subscripts and Greek letters.
- Display formulas: the quadratic formula and a sum whose limits
  stand above and below the operator.
- `\left` and `\right` delimiters that stretch to their content,
  floor brackets, primes, and an integral with its limits beside the
  operator.
- The strict dollar rule: prices such as `$5` and `$10` stay text,
  because a closing dollar may not be followed by a digit and an
  opening dollar may not be followed by a space.

The math engine needs a font with an OpenType MATH table. The
stylesheet sets it on the `math` element that glu generates from the
dollar syntax:

```css
@font-face {
  font-family: "Latin Modern Math";
  src: url("latinmodern-math.otf");
}
math { font-family: "Latin Modern Math"; font-size: 12pt; }
```
