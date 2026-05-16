# Numbered sections — CSS-counter variant

Same Skatordnung-style hanging-indent layout as `../numbered-sections/`,
but the section numbers are NOT typed into the HTML — they are computed
at render time by CSS counters.

Three nested `<ol class="sec">` declare the hierarchy. Each level

```css
ol.sec       { counter-reset: sec; }
ol.sec > li  { counter-increment: sec; }
ol.sec > li::before { content: counters(sec, ".") "  "; }
```

`counters(name, sep)` (note the trailing `s`) joins the values of every
ancestor counter with that name along the chain, so nesting depth one
produces `"2"`, depth two `"2.1"`, depth three `"2.1.1"`. To start the
outermost counter at 2 (matching the Skatordnung's Chapter 2) the very
top `<ol>` carries `counter-reset: sec 1` — the first child `<li>` then
increments it to 2.

## Run

```
glu numbered-sections-counters.html
```

(produces `numbered-sections-counters.pdf`; this directory ships a
copy as `result.pdf` plus a rendered preview as `firstpage.png`.)

## Result

![first page of result.pdf](firstpage.png)

## Compare

- `../numbered-sections/` writes the numbers literally into the HTML
  as `<td>`s. Use that variant when the structure is sparse and you
  want absolute control over which numbers appear where.
- This variant binds the numbers to the document structure. Adding or
  removing an `<li>` automatically renumbers everything below it; no
  manual fix-up. The cost is a stricter HTML shape (everything must
  live inside the right `<ol class="sec">`).

## Centred chapter title with a gutter marker

The outer `<li>`'s chapter title is rendered with `text-align: center`
on a block container, while its marker still hangs in the gutter
alongside the other markers. That combination works because Mknodes
wraps a `<li>::before` prepend in a (-fil, prepend, +fil) glue pair
when the paragraph alignment is centre or right — the leading -fil
cancels the LineStartGlue added by the linebreaker, so the prepend
anchors at the line-start edge regardless of where the centred body
text ends up.
