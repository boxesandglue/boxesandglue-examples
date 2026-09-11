# Running footer (CSS GCPM running elements)

A two-page document with a rich, repeating page footer driven entirely
from CSS: a `<footer>` element is taken out of the normal flow with
`position: running(pagefooter)` and placed into the `@bottom-center`
page margin box on **every** page via `content: element(pagefooter)`.
No Go and no Lua callback needed.

## What is exercised

| Feature | How |
| --- | --- |
| `position: running(name)` | Removes the `<footer>` from the flow and registers it under the name `pagefooter`. It occupies no space at its source position. |
| `@page { @bottom-center { content: element(name) } }` | Places the captured element into the bottom margin box, re-formatted at the margin box width, on every page. |
| Rich footer content | The footer body is real HTML: a three-column table with `<br>` line breaks at `font-size: 8pt`, incl. a `border-top` rule line. The element keeps its own computed styles. |
| Fixed position | The footer sits at the top edge of the 30&nbsp;mm bottom margin band on both pages; page 2 is half empty and the footer does not move up. |

## Files

| File | Role |
| --- | --- |
| `running-footer.html` | The runnable demo. |
| `result.pdf` | Reference output (2 pages). |
| `firstpage.png`, `secondpage.png` | Page previews. |

## Run

```
glu running-footer.html
```
