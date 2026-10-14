# 06 Image in a top float

An image with a caption inside an `fo:float` with `float="before"`:
the classic figure at the top of the page. The float holds an
`fo:external-graphic` and a small italic caption block. Both leave the
running text and go to the top of the page.

## Run

```
glu ../foproc.lua 06-image-float.fo out=out.pdf
```

Run this inside the directory. It writes `out.pdf`; the directory
ships a copy as `result.pdf`.

## Result

![first page of result.pdf](firstpage.png)
