# 05 — Three floats sharing one page

Three top-floats from three different paragraphs all stack on one
page. This is the case the two-pass page assembly is built for: the
first pass reserves the top-float region; the second pass paints the
buffered body below the final reservation, so multiple floats per
page work without reflow surprises.

## Run

```
glu 05-three-floats-one-page.html
```

(produces `05-three-floats-one-page.pdf`; this directory ships a copy
as `result.pdf`.)

## Result

![first page of result.pdf](firstpage.png)
