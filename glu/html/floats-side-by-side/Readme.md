# Floats next to each other

A short article on an A5 page with floats that stand next to each
other: two figures on the left, and a box of facts with a picture
beside it on the right.

| Block | What to look at |
| ----- | --------------- |
| `.figure` | Two left floats in a row. The second one starts at the outer edge of the first one's margin box. |
| text beside them | The lines give way to both figures, then, where the shorter one ends, to the taller one alone. |
| `.facts` + `img.right` | The same on the right: the box shrinks to its longest line, the picture stands to its left. |
| `h2` | `clear: both` starts each section below the floats before it. |

## How it works

```css
.figure { float: left; margin: 0 3mm 2mm 0; }
.tall   { width: 22mm; }
.short  { width: 20mm; }
.facts  { float: right; margin: 0 0 2mm 3mm; padding: 2mm 3mm; }  /* no width */
.right  { float: right; width: 16mm; margin: 0 0 2mm 3mm; }
h2      { clear: both; }
```

A float opening while another one on its side is still there stands
beside it, as in a browser. Each line keeps clear of the float that
reaches furthest in at its height, so the measure widens step by step
as the floats end. Where there is no room left for text beside the
floats already there, the new float goes below the one that ends
first.

The margin between two floats is their own: `-bag-float-gutter` only
keeps text off a float, so two floats without margins touch.

## Run

```bash
glu floats-side-by-side.html
```
