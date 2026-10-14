# Inline MathML (accessible, PDF/UA-2)

`<math>` elements written directly in the HTML are set with the
OpenType MATH engine of boxes and glue, using the MATH table of Latin
Modern Math. No Pandoc, no JavaScript and no external converter are
involved: glu reads the MathML itself, and the output is deterministic.

Rendered as PDF/UA-2, each formula also becomes a tagged `Formula`
structure element. It carries a plain-text `/Alt` fallback and the
original MathML as an associated file (`/AFRelationship /Supplement`),
so assistive technology can read the math semantically. pdfa11y reports
`Verdict: PASS` (0 fail).

## What is exercised

| Formula                                          | MathML elements                                     | What the engine does                      |
| ------------------------------------------------ | --------------------------------------------------- | ----------------------------------------- |
| Pythagoras `a² + b² = c²`                        | `<msup>`, `<mo>`, `<mi>`                            | Inline atoms with Bin/Rel spacing         |
| Quadratic formula                                | `<mfrac>`, `<msqrt>`, nested `<msup>`               | Inline fraction, radical and scripts      |
| Gauss summation `∑ k = n(n+1)/2`                 | `<munderover>`, `<mfrac>`, big-op `<mo>∑</mo>`      | Display style, limits above and below     |
| Indexed n-th root of `∑ x_i²`                    | `<mroot>`, `<munderover>`, `<msubsup>`              | Radical with degree and a nested big-op   |
| Derivative `d/dx sin(x) = cos(x)`                | `<mi>` (italic variable, upright function name)     | Automatic `mathvariant`                   |

## How it works

htmlbag treats a `<math>` element as foreign content and passes the
subtree to the MathML reader, which turns it into math atoms with the
glyphs of the math font. The math engine sets them as an hlist that
sits in the surrounding paragraph like a word. `display="block"`
switches to display style.

The `math` element gets its own `font-family` in the stylesheet, which
has to name a font with an OpenType MATH table. This example bundles
`latinmodern-math.otf` for that.

## MathVariant defaults

- `<mi>x</mi>` (single character) defaults to italic and is mapped to
  the Mathematical Italic alphabet (U+1D44E ff for lowercase, U+1D434 ff
  for uppercase), so the font renders `𝑥`, not the upright ASCII glyph.
- `<mi>sin</mi>` (several characters) defaults to upright ASCII glyphs,
  the usual convention for function names.
- `<mi mathvariant="normal">x</mi>` forces upright on a single
  character.
- Special case: `<mi>h</mi>` maps to U+210E (Planck constant ℎ) because
  U+1D455 is a reserved Unicode slot.

## Run

```bash
glu mathml.html -o out.pdf
```

The document describes itself: `<meta name="pdf-format"
content="PDF/UA-2">` in the head switches on PDF 2.0 and structure
tagging, and the title comes from the `<title>` element, so no command
line flag is needed. A `--format` flag, if given, overrides the meta
tag. This directory ships the tagged `result.pdf` and a preview of its
first page as `firstpage.png`.

## Result

![first page of result.pdf](firstpage.png)

## Accessible math (PDF/UA-2)

Each `<math>` becomes a `Formula` structure element. For an inline
formula the marked content of the surrounding paragraph is split, so
the reading order is `text · formula · text`, not `text · text ·
formula`:

```
<P>
 ├─ MCID 0   "The Pythagorean relation "   (paragraph text before)
 ├─ <Formula>   /Alt "a 2 + b 2 = c 2"   /AF → formula.mml
 │    └─ MCID 1                           (formula glyphs)
 └─ MCID 2   " holds for every …"         (paragraph text after)
```

- **`/Alt`** is a plain-text fallback. It is taken from the MathML
  `alttext` attribute when present, otherwise from the content of the
  token elements (`<mi>`, `<mn>`, `<mo>`, `<mtext>`) in document order.
- **`/AF`** is the MathML source embedded as an associated file
  (`application/mathml+xml`, `/AFRelationship /Supplement`). The
  `xmlns="http://www.w3.org/1998/Math/MathML"` namespace is added again,
  so the file is self-describing XML. A MathML-aware reader uses it for
  the full semantics.

Verify:

```
pdfinfo result.pdf            # PDF version: 2.0, Tagged: yes
pdfa11y result.pdf            # Verdict: PASS (including the formula checks UA-17-*)
verapdf --flavour ua2 result.pdf
```

Under `--format PDF/UA` (UA-1, PDF 1.7) the `Formula` element and its
`/Alt` are still written, but the MathML associated file is not:
associated files are a PDF 2.0 feature.

## Supported elements

```
<math>, <mrow>, <mstyle>, <mpadded>, <mphantom>     -- containers
<mi>, <mn>, <mo>                                    -- token elements
<mfrac>, <msqrt>, <mroot>                           -- fraction / radical
<msup>, <msub>, <msubsup>                           -- script attachment
<munder>, <mover>, <munderover>                     -- limits / accents
<mspace>                                            -- explicit spacing
<semantics> (transparent), <annotation*> (skipped)
```

Not supported yet:

- `<mtable>`, `<mtr>`, `<mtd>` (matrices)
- `<mtext>` (text content is skipped)
- `<menclose>` (boxed expressions)
- `mathvariant` values other than `italic` and `normal`
  (bold, double-struck, fraktur, sans-serif and so on)
- Italic mapping for Greek letters (only ASCII a to z and A to Z are
  mapped)
