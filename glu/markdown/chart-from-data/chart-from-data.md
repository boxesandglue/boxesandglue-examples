---
title: "Monthly Sales 2025"
author: "Reporting Pipeline"
lang: en
---

# Monthly Sales 2025

This report visualises sales values entirely server-side: a Lua block
below computes scaling, axes and bar geometries from a plain Lua table,
writes the result to `chart.svg`, and glu inlines it into the PDF as a
regular image. No JavaScript engine, no headless browser, no external
chart library — just data in, SVG out, PDF rendered.

The same pattern scales to JSON feeds, database queries or aux values
from earlier passes. Because the SVG is a pure function of the input
data, identical inputs produce byte-identical PDFs.

```{lua}
local data = {
    { month = "Jan", value = 142 },
    { month = "Feb", value = 168 },
    { month = "Mar", value = 195 },
    { month = "Apr", value = 210 },
    { month = "May", value = 187 },
    { month = "Jun", value = 224 },
    { month = "Jul", value = 251 },
    { month = "Aug", value = 233 },
    { month = "Sep", value = 198 },
    { month = "Oct", value = 215 },
    { month = "Nov", value = 240 },
    { month = "Dec", value = 268 },
}

local W, H = 600, 280
local pad_l, pad_r, pad_t, pad_b = 50, 10, 20, 40
local plot_w = W - pad_l - pad_r
local plot_h = H - pad_t - pad_b

local max = 0
for _, d in ipairs(data) do
    if d.value > max then max = d.value end
end
-- Round max up to the next multiple of 50 for nicer axis ticks
max = math.ceil(max / 50) * 50

local bar_w = plot_w / (#data * 1.6)

local parts = {
    string.format(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 %d %d">',
        W, H),
}

-- Horizontal gridlines + y-axis labels
for i = 0, 4 do
    local y = pad_t + plot_h - plot_h * i / 4
    local v = math.floor(max * i / 4)
    parts[#parts + 1] = string.format(
        '<line x1="%d" y1="%.2f" x2="%d" y2="%.2f" stroke="#dddddd" stroke-width="0.5"/>',
        pad_l, y, W - pad_r, y)
    parts[#parts + 1] = string.format(
        '<text x="%d" y="%.2f" font-size="11" text-anchor="end" fill="#555555" font-family="sans">%d</text>',
        pad_l - 6, y + 4, v)
end

-- Bars + month labels
for i, d in ipairs(data) do
    local cx = pad_l + (i - 0.5) * (plot_w / #data)
    local h = plot_h * d.value / max
    local x = cx - bar_w / 2
    local y = pad_t + plot_h - h
    parts[#parts + 1] = string.format(
        '<rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" fill="#2D6A4F"/>',
        x, y, bar_w, h)
    parts[#parts + 1] = string.format(
        '<text x="%.2f" y="%.2f" font-size="10" text-anchor="middle" fill="#333333" font-family="sans">%d</text>',
        cx, y - 4, d.value)
    parts[#parts + 1] = string.format(
        '<text x="%.2f" y="%d" font-size="11" text-anchor="middle" fill="#555555" font-family="sans">%s</text>',
        cx, H - pad_b + 16, d.month)
end

parts[#parts + 1] = '</svg>'

local svg = table.concat(parts, "\n")
local f = assert(io.open("chart.svg", "w"))
f:write(svg)
f:close()

return '<img src="chart.svg" width="14cm">'
```

## How it works

The Lua block above runs during Markdown processing. Its return value
replaces the block in the source, so the generated `<img>` tag is what
goldmark sees. htmlbag then loads `chart.svg` from disk and embeds it
as a vector graphic in the final PDF.

Three glu/Lua features carry the workflow:

1. **Lua blocks in Markdown** (`` ```{lua} `` … `` ``` ``) — anything
   that returns a string substitutes into the document.
2. **Full Lua standard library** — `io.open`, `string.format`,
   `table.concat` are all available in the default (non-`--safe`) mode.
3. **htmlbag SVG support** — any `<img src="*.svg">` is rendered as
   vector content, not rasterised.

## What about JavaScript-based charts?

For traditional dashboards driven by Chart.js or D3, the usual approach
is to render the chart in a headless browser and snapshot it. Pipelines
like the one above sidestep that entirely: no Chromium process, no
race on "when did the chart finish drawing", no 150 MB of Chromium in
the deployment image. The chart is just data, deterministically
serialised to SVG, and the rendering happens in glu itself in a few
milliseconds.
