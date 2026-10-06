# Text around images with `float: left | right`

A short article on an A5 page with three floats the text flows around:
a picture with its caption, an image at the start of a paragraph, and a
box of facts that is only as wide as its longest line.

| Block | What to look at |
| ----- | --------------- |
| `.figure` | Picture and caption in one floated block with a declared width; the image fills it. |
| `img.left` | An image as the first thing in a paragraph floats at the paragraph's first line. |
| `.facts` | A float without a width shrinks to its longest line. |
| `h2` | `clear: both` starts each section below the floats before it. |

## How it works

```css
body     { -bag-float-gutter: 4mm; }   /* space between float and text */
.figure  { float: right; width: 36mm; }
img.left { float: left; width: 17mm; }
.facts   { float: right; padding: 2mm 3mm; }  /* no width */
h2       { clear: both; }
```

The lines beside a float are shortened by its width plus the gutter for
as many lines as the float is tall. A float's margin on the side of the
text replaces the gutter where it is positive.

The pictures are SVG files; raster images (PNG, JPEG, PDF) float the
same way.

## Run

```bash
glu image-runaround.html
```

The how-to on [boxesandglue.dev](https://boxesandglue.dev/glu/howto/image-runaround/)
walks through it step by step.
