# DIN 5008 letter from Markdown

A complete German business letter (DIN 5008 Form B layout) written
in Markdown plus a small CSS class library. The fixed-position slots
— sender, recipient address, date, fold marks — all use `position:
absolute` to anchor against the page area, while the subject and
body flow normally.

## What's in here

| File | Purpose |
| --- | --- |
| `letter-din5008.md` | The letter content. Frontmatter wires up `letter-din5008.css`; positioned slots are tagged with raw `<div class="…">`. |
| `letter-din5008.css` | DIN 5008 slot positions: recipient at 4.5 cm/2 cm, sender at 2.7 cm/12.5 cm, fold marks at 10.5 cm and 21 cm, date right-aligned at 9.7 cm. |
| `result.pdf` | Committed snapshot of the rendered output. |
| `firstpage.png` | Preview thumbnail. |

## Run

```
glu --clean letter-din5008.md
```

This produces `letter-din5008.pdf`. To verify against the committed snapshot:

```
SOURCE_DATE_EPOCH=0 glu --clean letter-din5008.md -o out.pdf
md5 out.pdf result.pdf   # both hashes should match
```

## Why the layout works

DIN 5008 standardises the **address-field position** so a folded
DIN A4 letter sits correctly in a DIN Lang envelope window: the
recipient block has to start exactly 45 mm from the sheet's top
edge and be 85 × 45 mm. CSS `position: absolute` with `top: 4.5cm;
left: 2.5cm; width: 8.5cm; height: 4.5cm` produces exactly that.

The **fold marks** at 105 mm and 210 mm let you tri-fold the
printout for a DIN Lang envelope. They anchor at `left: 0` because
the page's left margin would otherwise push them inside the
content area; `position: absolute` resolves against the page area,
which for `left: 0` means the physical left edge of the page.

The **subject and body** stay in the normal flow. The subject's
`margin-top: 12.7cm` clears the recipient and date blocks above and
gives a comfortable gap before the salutation. Everything from
"Dear Sir or Madam" onward is just regular Markdown.

## What this exercises in htmlbag

- `position: absolute` with `top`/`left` (recipient, fold marks,
  punch mark).
- `position: absolute` with `top`/`right` (date — anchored to the
  right edge, content `text-align: right`).
- `position: absolute` with mixed offsets where the box's own
  geometry derives from explicit `width:`/`height:` declarations.
- Multi-element source-order paint sequence (sender, recipient,
  three fold marks, date) without z-index conflicts.

`position: relative` is supported for horizontal offsets only in
v1 — see the implementation plan for status.

## Customising

The class names in `letter-din5008.css` are deliberately neutral
(`letter-sender`, `letter-recipient`, etc.) so you can drop the
file into your own letter templates unchanged. Override the
offset values in your own stylesheet if you have a different
envelope window position or a corporate-design grid.
