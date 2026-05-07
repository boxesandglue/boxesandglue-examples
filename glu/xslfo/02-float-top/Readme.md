# 02 — Top float

A `fo:float[float="before"]` carrying a caption plus a supporting block.
The float is reserved at the top of the page during htmlbag's first pass;
body content flows below the reservation in the second pass.

## Run

```
glu ../foproc.lua 02-float-top.fo out=result.pdf
```

## Result

![first page of result.pdf](firstpage.png)
