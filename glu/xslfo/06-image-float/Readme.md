# 06 — Image in a top float

Image plus caption inside a `fo:float[float="before"]` — the classic
"figure at the top of the page" pattern. The float wraps an
`fo:external-graphic` and a small italic caption block; both are
pulled out of the running flow and stacked in the top-float region.

## Run

```
glu ../foproc.lua 06-image-float.fo out=result.pdf
```

## Result

![first page of result.pdf](firstpage.png)
