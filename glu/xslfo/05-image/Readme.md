# 05 — Image in flow

`fo:external-graphic` referencing the bundled `../ocean.pdf`. Because
the source is a PDF, gofpdi imports it as a Form XObject — vector
content is preserved at any zoom level. `width="80mm"` is set; height
is left to scale automatically.

## Run

```
glu ../foproc.lua 05-image.fo out=result.pdf
```

## Result

![first page of result.pdf](firstpage.png)
