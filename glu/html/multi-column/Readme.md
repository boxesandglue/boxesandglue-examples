# Multi-column layout

A one-page article set in two columns with CSS Multi-column Layout:
`column-count` and `column-gap` on the `body` make every page hold two
columns, filled one after the other. The title and the lead span both
columns, and the columns of the last page are balanced.

![first page of result.pdf](firstpage.png)

## What is exercised

| Feature | How |
| --- | --- |
| `column-count`, `column-gap` | `body { column-count: 2; column-gap: 7mm; }`: two columns of 83.5 mm on an A4 page with 174 mm of content width. |
| `column-span: all` | The `h1` and the lead paragraph are as wide as the page; the columns start below them. |
| Balancing | The text of the last page is spread so that both columns end at about the same height (`column-fill: balance`, the initial value). |
| Column breaks | Headings keep with the next paragraph (`break-after: avoid`) across the column break as across a page break; a paragraph is split between the columns. |
| Side float | The pull quote (`float: right`) stays in its column, and the text of the column runs around it. |
| Footnote | Placed at the foot of the column that holds it, as wide as the column. |
| Page margin boxes | The page number belongs to the page, not to a column. |

## Limits

`column-count` is laid out on the `body` and on a direct child of the
`body` without a border, a background or padding, whose siblings then
span the columns. `column-rule` is read but not drawn yet. A footnote
in a paragraph that is split between columns is placed in the column
where the paragraph starts
([htmlbag#96](https://github.com/boxesandglue/htmlbag/issues/96)).

## Run

```
glu multi-column.html
```
