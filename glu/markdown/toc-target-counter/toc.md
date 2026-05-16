---
title: PDF typography with boxes and glue
author: glu
papersize: a5
lang: en
css: toc.css
---

# Table of contents

<div class="toc">

- [Introduction](#introduction)
- [Line breaking](#linebreaking)
- [Hyphenation](#hyphenation)
- [Floats and inserts](#floats)
- [Closing remarks](#closing)

</div>

## Introduction {#introduction}

This document demonstrates automatic cross-references with page numbers.
The table of contents above is not filled in by hand. The numbers after
each link are rendered in CSS via `target-counter(attr(href), page)`.

The first glu pass does not yet know the page numbers and renders `?`.
The next pass, after the anchor positions have been written to the aux
file, has the real values. glu's multi-pass loop converges automatically.

## Line breaking {#linebreaking}

The TeX algorithm by Knuth and Plass minimises global badness instead of
breaking greedily line by line. boxes and glue ports it to Go.

A paragraph turns into a list of glyph, box, and glue nodes. The solver
picks the decomposition with the lowest total cost, which means fewer
orphans and widows than greedy CSS line breaking gives you.

## Hyphenation {#hyphenation}

The hyphenation patterns follow Liang/Knuth. CSS Text 3 `hyphens: auto`
and `hyphens: manual` are supported, and soft-hyphens (`&shy;`) are
honoured.

## Floats and inserts {#floats}

Floats can be anchored to the top or bottom of a page via the CSS
`float` property. Footnotes use the same insert mechanism but live in
their own class with a separator rule.

## Closing remarks {#closing}

The table of contents at the top of this document is the demonstration
of `target-counter()`. Try what happens when you add or remove a
section: all following page numbers update automatically as soon as glu
runs its second pass.
