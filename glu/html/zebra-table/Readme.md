# Zebra-striped table — CSS3 structural selectors

Smoke test that proves csshtml + htmlbag actually honour the CSS3
structural selector family end to end. No `class=` attributes on the
data rows: every visual differentiation is driven by selectors over
the document structure.

## What is exercised

| Selector                                       | Visible effect                              |
| ---------------------------------------------- | ------------------------------------------- |
| `tr:nth-child(even)`                           | alternating row fill                        |
| `tbody tr:nth-of-type(2) td:nth-child(3)`      | the red bold price in row 2                 |
| `td:not(:first-child)`                         | right-aligned numeric columns               |
| `tbody tr:first-child td`                      | thick top rule below the header             |
| `tbody tr:last-child td`                       | suppressed bottom rule on the last row      |
| `h1:first-child`                               | no extra top margin on the heading          |
| `thead tr`, `thead th`                         | header fill + bold                          |
| `tfoot tr`, `tfoot td`                         | bold totals row separated by a heavy rule   |

Internally bag delegates selector parsing and matching to
[`cascadia`](https://github.com/andybalholm/cascadia); csshtml then
folds the matched rules into the HTML tree as `!`-prefixed attributes
ordered by specificity (`csshtml/tree.go`). That means anything
cascadia understands works without further bag-side code — CSS3
structural selectors all qualify.

## Run

```
glu zebra-table.html
```

(produces `zebra-table.pdf`; this directory ships a copy as
`result.pdf` plus a rendered preview as `firstpage.png`.)

## Result

![first page of result.pdf](firstpage.png)

## `<tfoot>` support

htmlbag's table builder runs three passes: `<thead>` rows are
collected first, then `<tbody>` rows, then `<tfoot>` rows. Footer
rows are appended last to the table's row list (HTML5 §4.9 renders
`<tfoot>` at the bottom of the table irrespective of source order)
and are tagged with the `TFoot` structure element in PDF/UA output.
`frontend.Table.FooterRows` mirrors `HeaderRows` so the tagging pass
can find the trailing footer slice.
