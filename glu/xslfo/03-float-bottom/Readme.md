# 03 — Bottom float

A `fo:float[float="after"]` anchored above the footnote zone. The
painting order on the page is: top-floats → body → bottom-floats →
footnotes (see `htmlbag/insert.go::flushInserts`).

## Run

```
glu ../foproc.lua 03-float-bottom.fo out=result.pdf
```

## Result

![first page of result.pdf](firstpage.png)
