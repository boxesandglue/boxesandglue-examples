---
title: Table column widths
lang: en
css: table-column-widths.css
---

# Table column widths

By default glu sizes table columns automatically: each column ends up as
wide as its content needs. A `width` on a `<td>` or `<th>` overrides that
measurement, so the layout stays put however long the text turns out.

## An even split that stays even

The classic case is a signature block. Both cells declare `width: 50%`,
so the right-hand column starts at the same position in both tables even
though they hold different amounts of text.

<table class="signature">
  <tr>
    <td style="width:50%">Place, date</td>
    <td style="width:50%">For the client</td>
  </tr>
</table>

<table class="signature">
  <tr>
    <td style="width:50%">Berlin, 3 March 2026</td>
    <td style="width:50%">For the contractor, represented by the managing director</td>
  </tr>
</table>

Leave the widths out and each column shrinks to its own content, so the
two blocks drift apart and the signature lines no longer align.

## Percentages and absolute lengths

A percentage resolves against the width of the table, an absolute length
is taken as it is. A percentage is therefore only as meaningful as the
table it refers to: a table shrinks to its content unless told
otherwise, so the stylesheet sets `table { width: 100% }` first.

<table>
  <tr>
    <td style="width:25%">25 percent</td>
    <td style="width:75%">75 percent, so this column is three times as wide as its neighbour.</td>
  </tr>
</table>

<table>
  <tr>
    <td style="width:4cm">Exactly 4 cm</td>
    <td>Whatever is left over: declaring a width for only some columns
    is fine, the undeclared ones share what remains.</td>
  </tr>
</table>

## Sizing a Markdown table from CSS

Pipe tables have nowhere to put a `style` attribute, so their columns are
sized from the stylesheet with `nth-child`. Wrapping the table in a
`<div class="terms">` gives the rule something to hook onto: the table is
a descendant, not the element carrying the class. Name `th` and `td`
alike, or the header row keeps its automatic width.

```css
.terms table th:nth-child(1), .terms table td:nth-child(1) { width: 22% }
```

<div class="terms">

| Property | Value | Effect |
|----------|-------|--------|
| `width` | percentage | Share of the table width. |
| `width` | length | Fixed column width, e.g. `4cm` or `120pt`. |
| `width` | omitted | Column is measured from its content. |

</div>

## What the width really promises

A declared width is the column's preferred *and* minimum size.

<table>
  <tr>
    <th style="width:34%">Situation</th>
    <th style="width:66%">Outcome</th>
  </tr>
  <tr>
    <td>Content needs more room than declared</td>
    <td>It wraps, and is never clipped: a word too long to fit still
    widens the column.</td>
  </tr>
  <tr>
    <td>Widths add up to more than 100%</td>
    <td>All of them scale down proportionally. Two columns asking for
    80% each end up with 50% apiece.</td>
  </tr>
  <tr>
    <td>Width on a cell spanning columns</td>
    <td>Ignored: it belongs to no single column. Declare it on a row
    without <code>colspan</code> instead.</td>
  </tr>
</table>
