# Lines in register with `line-snap`

Two columns whose lines stand level, whatever the headings, tables and
floats between them do. Page 1 is set with `line-snap: baseline`, page
2 repeats the text without it, so the columns drift apart there. The
red lines are the grid, drawn by `-bag-trace: linegrid`: remove that
declaration for the final document.

| Block | What to look at |
| ----- | --------------- |
| `body` | `line-snap: baseline` is inherited, so all text snaps to the grid of the page. |
| `h1`, `h2` | `line-snap: none` leaves the headings free. The margins around them take up the rest. |
| `.figure` | A top float declared in the middle of the text. It moves the lines placed before it by a whole number of lines. |
| `table` | A table is not snapped. The line after it goes back to the grid. |
| `.free` | Turns the snapping off for the comparison on page 2. |

## How it works

The grid belongs to the page and starts at the top of the page area.
Its distance is the `line-height` of the running text, or `-bag-line-grid`
in an `@page` rule. A number at the right edge of the page means the same
height in every column.

The piece between two snapped lines becomes a multiple of the grid. What
is left over goes into the margins of that piece, in proportion to them,
and the trace prints it to the left of the line that moved, such as `+5pt`.

```css
body {
  line-height: 12pt;
  column-count: 2;
  line-snap: baseline;
}
h2 {
  line-snap: none;
}
```
