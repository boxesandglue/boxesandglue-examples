# chart-from-data

Server-side chart generation: a Lua block inside Markdown turns a plain
data table into an SVG bar chart, writes it to disk, and embeds it in
the PDF via a regular `<img>` tag.

![Preview](firstpage.png)

## Run it

```
glu chart-from-data.md
```

This produces `chart-from-data.pdf` (this directory ships a copy as
`result.pdf`) and a side-effect `chart.svg` that you can inspect or
delete after the render.

## Why this matters

Charts are the most common reason teams reach for headless Chrome or
a JavaScript renderer in PDF pipelines. This example shows that for
many reporting use cases you can stay pure-Go:

- **Deterministic** — same input data produces a byte-identical SVG
  and byte-identical PDF, guarded by the regression test in
  `rake check_glu_examples`.
- **Fast** — sub-50ms end-to-end, no Chromium startup tax.
- **No external runtime** — no Node, no Chrome, no Python. Just glu
  and the Lua block.

## Extending the pattern

| Change | How |
|--------|-----|
| Read data from a JSON file | `glu.json.decode(io.open("data.json"):read("a"))` |
| Use values from a previous pass | Read `_aux.your_key` in the Lua block |
| Multiple charts in one report | Repeat the block; vary the output filename |
| Different chart type | Replace the bar geometry with line / area / pie path computations |

For more complex charts, factor the SVG generation into a companion
`chart-from-data.lua` file and call helpers from the Markdown block.
