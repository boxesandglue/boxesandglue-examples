---
title: TeX math in Markdown
lang: en
format: PDF/UA-2
css: tex-math.css
math: true
---

# TeX math in Markdown

Turn on `math: true` in the frontmatter and write formulas with TeX
dollar syntax. Inline math goes between single dollars, display math
between double dollars. The TeX is converted to MathML and rendered by
the same engine that powers the `<math>` HTML example, so it inherits
Formula tagging and, under PDF/UA-2, the MathML associated file.

## Inline math

The mass-energy equivalence $E=mc^2$ sits inline with the prose, as does
a variable like $x$ or a subscripted one like $a_{i}$. Greek letters work
too: the angle $\theta$ and the wavelength $\lambda$.

## Display math

The quadratic formula, set as a display equation:

$$x=\frac{-b\pm\sqrt{b^2-4ac}}{2a}$$

A summation in display style, where the engine enlarges the operator and
places the limits above and below:

$$\sum_{i=1}^{n} i = \frac{n(n+1)}{2}$$

## Fences, floors and primes

Delimiters written with `\left` and `\right` stretch to the content
they enclose, floor brackets come from `\lfloor` and `\rfloor`, and
primes use the TeX apostrophe shorthand. An integral keeps its scripts
beside the operator (TeX treats it as nolimits), unlike the stacked
sum above:

$$f'(x) = \left( \frac{x}{2} \right)^2 + \left\lfloor \frac{n}{2} \right\rfloor + \int_0^1 x^2 \, dx$$

## Predictable dollars

The strict dollar rule keeps prose safe: prices such as $5 and $10 are
not formulas, because a closing dollar may not be followed by a digit and
an opening dollar may not be followed by a space. A literal `$x$` inside a
code span also stays verbatim.
