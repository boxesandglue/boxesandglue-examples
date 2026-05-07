# 01 — Basic walker

Smallest end-to-end XSL-FO walker test: page master, blocks, inline markup
(bold / italic / colour) and two footnotes. Exercises the non-float code
path of `foproc.lua`.

## Run

```
glu ../foproc.lua 01-basic.fo out=result.pdf
```

## Result

![first page of result.pdf](firstpage.png)
