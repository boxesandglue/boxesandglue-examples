# 05 Image in the flow

An `fo:external-graphic` that references the shared `../ocean.pdf`.
Because the source is a PDF, it is embedded as a Form XObject, so the
vector content stays sharp at any zoom level. Only `width="80mm"` is
set; the height follows from the aspect ratio.

## Run

```
glu ../foproc.lua 05-image.fo out=out.pdf
```

Run this inside the directory. It writes `out.pdf`; the directory
ships a copy as `result.pdf`.

## Result

![first page of result.pdf](firstpage.png)
