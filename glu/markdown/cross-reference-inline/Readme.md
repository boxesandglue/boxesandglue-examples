# Cross-references with inline anchors

This example shows CSS `target-text()` and `target-counter()` resolving
against **inline** anchor targets (`<span id="...">`) as well as
block-level ones (`<h1 id="...">`). The link text and the page number
of every reference are generated in CSS, not typed into the source.

The key idea: an `<a class="ref" href="#some-id"></a>` carries no
text of its own. CSS fills it in:

```css
a.ref::before { content: target-text(attr(href)); }
a.ref::after  { content: " (p. " target-counter(attr(href), page) ")"; }
```

`target-text` pulls the captured text from the anchor element, whether
that anchor is an inline `<span>` or a block heading. `target-counter`
pulls the page where the anchor was placed. Both are resolved from the
aux file that glu writes on each pass. It is named after the output
file, so the command below writes `out-aux.json`.

## Run

```
glu refs.md -o out.pdf
```

## What gets tracked

| Source                                         | Type           |
|------------------------------------------------|----------------|
| `<span id="thm-bw">the Bolzano–Weierstrass …`  | inline anchor  |
| `<span id="thm-mvt">the mean value theorem`    | inline anchor  |
| `# Setup {#setup}`                             | block anchor   |
| `# Application {#application}`                 | block anchor   |

A reference like `<a class="ref" href="#thm-bw"></a>` renders as
*the Bolzano–Weierstrass theorem (p. 1)*. Move or rename a section,
and every reference updates on the next render pass.

## Anchor text capture

The text shown by `target-text(attr(href))` is the text content of
the referenced element at collection time:

- Inline anchors keep their span text verbatim
  (`"the Bolzano–Weierstrass theorem"`).
- Block anchors keep the rendered heading text (`"Application"`).
- Anchor texts over 200 characters are truncated with a trailing `…`
  to keep the aux file bounded. This mostly affects block anchors;
  inline anchors are usually well below that.

## Multi-pass details

`glu` runs the document twice (sometimes three times) before the
output stabilizes:

1. **Pass 1.** Anchor positions are unknown. Every reference renders
   as `?` for both text and page. The anchors are collected and
   written to the aux file together with their captured text.
2. **Pass 2.** The aux file is read back. References now show the real
   text and the real page numbers.
3. **Pass 3 (rare).** This pass runs only if the wider references move
   line breaks around and change the page some anchor sits on.

The default is `--max-passes 3`. If that isn't enough (heavy
back-references with many changes in text length), pass
`--max-passes 5`.

## Result

![first page of result.pdf](firstpage.png)

## Reproducing result.pdf

`result.pdf` is built with `SOURCE_DATE_EPOCH=0`:

```
SOURCE_DATE_EPOCH=0 glu refs.md -o out.pdf
md5 out.pdf result.pdf   # both hashes must match
```

## Related examples

- [`../toc-target-counter/`](../toc-target-counter/) uses the same
  mechanism for an automatic table of contents with a dot leader and
  right-aligned page numbers.
