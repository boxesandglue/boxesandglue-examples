# DIN 5008 letter from Markdown

A complete business letter in the DIN 5008 Form B layout, written in
Markdown plus a small CSS class library. The fixed-position slots
(sender, recipient address, date, fold marks and punch mark) all use
`position: absolute` to anchor against the page area, while the subject
and body flow normally.

The how-to on the website explains the layout step by step:
<https://boxesandglue.dev/glu/howto/letter-din5008/>.

## What's in here

| File | Purpose |
| --- | --- |
| `letter-din5008.md` | The letter content. The frontmatter loads `letter-din5008.css`; positioned slots are raw `<div class="…">` elements. |
| `letter-din5008.css` | DIN 5008 slot positions (top/left): recipient at 4.5 cm/2 cm, sender at 2.7 cm/12.5 cm, fold marks at 10.5 cm and 21 cm, punch mark at 14.85 cm, date right-aligned at 9.7 cm. |
| `result.pdf` | Snapshot of the rendered output. |
| `firstpage.png` | Preview thumbnail. |

## Run

```
glu letter-din5008.md -o out.pdf
```

This writes `out.pdf`. To compare it with the snapshot:

```
SOURCE_DATE_EPOCH=0 glu letter-din5008.md -o out.pdf
md5 out.pdf result.pdf   # both hashes should match
```

The hashes match only with the glu version that rendered `result.pdf`.

## Why the layout works

DIN 5008 standardizes the **address field position** so a folded A4
letter sits correctly behind the window of a DIN Lang envelope: the
recipient block starts 45 mm from the top edge and 20 mm from the left
edge of the sheet and is 85 × 45 mm. CSS `position: absolute` with
`top: 4.5cm; left: 2cm; width: 8.5cm; height: 4.5cm` produces exactly
that.

The `@page` margin is zero, so the page area is the whole sheet and
the absolute offsets measure from the physical page edges, as DIN 5008
does. The body gets its margins back as padding.

The **fold marks** at 105 mm and 210 mm let you fold the printout in
three for a DIN Lang envelope. They sit at `left: 0`, the physical
left edge of the page.

The **subject and body** stay in the normal flow. The subject's
`margin-top: 10.2cm`, added to the body's top padding of 2.5 cm, puts
it 12.7 cm from the top of the page, clear of the recipient and date
blocks above. Everything from "Dear Sir or Madam" onward is regular
Markdown.

## What this exercises in htmlbag

- `position: absolute` with `top`/`left` (recipient, fold marks,
  punch mark).
- `position: absolute` with `top`/`right` (the date, anchored to the
  right edge, with `text-align: right`).
- `position: absolute` with mixed offsets where the box's own
  geometry comes from explicit `width`/`height` declarations.
- Several positioned elements painted in source order (sender,
  recipient, two fold marks, punch mark, date) without z-index
  conflicts.

`position: relative` on a block element only takes horizontal offsets
(`left`/`right`); `top` and `bottom` are ignored with a warning.

## Customizing

The class names in `letter-din5008.css` are deliberately neutral
(`letter-sender`, `letter-recipient` and so on) so you can drop the
file into your own letter templates unchanged. Override the offsets in
your own stylesheet if you have a different envelope window position
or a corporate design grid.
