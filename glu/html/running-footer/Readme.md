# Running footer (CSS GCPM running elements)

A two-page document with a rich page footer that repeats on every
page, driven entirely from CSS. A `<footer>` element is taken out of
the normal flow with `position: running(pagefooter)` and placed into
the `@bottom-center` page margin box on **every** page with
`content: element(pagefooter)`. No Go and no Lua callback needed.

## What is exercised

| Feature | How |
| --- | --- |
| `position: running(name)` | Removes the `<footer>` from the flow and registers it under the name `pagefooter`. It takes up no space at its source position. |
| `@page { @bottom-center { content: element(name) } }` | Places the captured element into the bottom margin box on every page, formatted again at the width of the margin box. |
| Rich footer content | The footer body is real HTML: a three-column table with `<br>` line breaks at `font-size: 8pt` and a `border-top` rule. The element keeps its own computed styles. |
| Fixed position | The footer is centered vertically in the 30&nbsp;mm bottom margin on both pages (`vertical-align: middle`, the default for the bottom boxes). Page 2 is half empty, and the footer does not move up. |

## Files

| File | Role |
| --- | --- |
| `running-footer.html` | The runnable demo. |
| `result.pdf` | Reference output (2 pages). |
| `firstpage.png`, `secondpage.png` | Page previews. |

## Run

```
glu running-footer.html -o out.pdf
```

This produces `out.pdf`.
