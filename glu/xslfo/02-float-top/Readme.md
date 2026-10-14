# 02 Top float

An `fo:float` with `float="before"` that holds a caption and a second
block. htmlbag reserves room for the float at the top of the page, and
the body text flows below it.

## Run

```
glu ../foproc.lua 02-float-top.fo out=out.pdf
```

Run this inside the directory. It writes `out.pdf`; the directory
ships a copy as `result.pdf`.

## Result

![first page of result.pdf](firstpage.png)
