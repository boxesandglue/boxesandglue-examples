# 03 Bottom float

An `fo:float` with `float="after"` placed at the bottom of the page,
above the footnote area. On each page htmlbag places top floats first,
then the body text, then bottom floats, then footnotes.

## Run

```
glu ../foproc.lua 03-float-bottom.fo out=out.pdf
```

Run this inside the directory. It writes `out.pdf`; the directory
ships a copy as `result.pdf`.

## Result

![first page of result.pdf](firstpage.png)
