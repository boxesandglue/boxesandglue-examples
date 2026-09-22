# Margin notes with `float: outside`

Notes that hang in the outer page margin, beside the paragraph they
belong to, on a book layout whose wide margin swaps sides from page to
page. The author never says which side a note goes to: `float: outside`
picks the right edge on right pages and the left edge on left pages.

| Block | What to look at |
| ----- | --------------- |
| `.note` | Hangs in the outer margin on every page; the paragraph beside it keeps its full measure. |
| `.figure` | A float to the outside edge with the text flowing beside it. On the left page the text gives way on the left. |
| `@page :left` | The wide margin is on the right of right pages and on the left of left pages. |

## How it works

`float: inside` and `float: outside` are resolved against the page the
float is painted on. The margins are read as written for a right page
and mirrored on left pages, so one rule serves both:

```css
.note {
  float: outside;
  width: 25mm;
  margin-left: 5mm;      /* the gap to the text */
  margin-right: -30mm;   /* pulls the note out into the margin */
}
```

The negative `margin-right` equals `width` plus `margin-left`, so the
note takes no room from the paragraph beside it. On a left page the two
horizontal margins swap and the note hangs out to the left instead.

A float starts level with the block after it: the margin between the
two blocks is laid out before the float, and the next block's top
margin collapses with it. The note's `margin-top` only makes up for its
smaller line height and font size, so the first baselines meet.

Content is laid out ahead of the page breaks, so a float is built for
the page that is current at the time. A margin note that ends up on a
page of the other parity is moved to its side when the page is painted.
A float that narrows the text beside it, like `.figure`, is rebuilt on
the page it lands on, so the lines give way on the correct side.

Limits: a float needs a declared width, and a float close to the bottom
of a page is not carried over to the next page with the text beside it.

## Run

```bash
glu margin-notes.html
```

This produces `margin-notes.pdf`. The checked-in `result.pdf`,
`firstpage.png` and `secondpage.png` were generated with
`SOURCE_DATE_EPOCH=0` so the bytes are reproducible; `rake check` in the
workspace root compares against them.
