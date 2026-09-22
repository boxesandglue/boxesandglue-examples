# Right-to-left paragraphs

Arabic paragraphs set in Amiri under `direction: rtl`, covering the
layout features that depend on which edge a line starts at. Everything
here is plain CSS; the bidi reorder and the Arabic shaping happen
automatically.

| Block | What to look at |
| ----- | --------------- |
| `text-align: start / end / center / justify` | `start` is the right edge and `end` the left edge. The last line of the justified paragraph is flush right. |
| `float: right` and `float: left` | The lines beside a float keep clear of it on the float's side; the text stays flush right on the other side. |
| `text-indent` | The first line is indented at the line start, which is the right edge. |
| Forced breaks with `hanging-punctuation: allow-end` | A line ending in `<br>` is not justified and stays flush right. The full stop before each break hangs out past the left edge of the line. |
| Latin run inside an Arabic paragraph | The Latin words and the number keep their left-to-right order inside the right-to-left line. |

## How it works

htmlbag hands the paragraph to boxesandglue in logical order with the
UAX #9 embedding level on every glyph. The line breaker works on that
order; afterwards every line is reordered visually (rules L1 to L4).
Two things are kept apart in that step:

- The insets and the two edge glues of a line (leftskip and line-end
  glue) are physical. `float: right` narrows the line from the right
  whatever the direction, and the reorder leaves the edge glues in
  place.
- `text-indent` and `text-align: start` / `end` are logical. htmlbag
  passes them as start-side values and boxesandglue resolves them to a
  physical side once the paragraph direction is known.

The line breaker also knows the paragraph direction
(`LinebreakSettings.TextDirection`, stamped on every line as
`HList.TextDir`). It uses that for the slack of a forced break, which
goes to the line end, and for hanging punctuation, which has to
protrude at the line end as well.

## Bundled font

| Font                | License                                |
| ------------------- | -------------------------------------- |
| `amiri-regular.ttf` | SIL OFL 1.1 (`amiri.license` included) |

## Run

```bash
glu rtl-paragraphs.html
```

This produces `rtl-paragraphs.pdf`. The checked-in `result.pdf` and
`firstpage.png` were generated with `SOURCE_DATE_EPOCH=0` so the bytes
are reproducible; `rake check` in the workspace root compares against
them.
