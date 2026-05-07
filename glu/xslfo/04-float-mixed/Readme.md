# 04 — All four insert classes

Top-float + body + bottom-float + footnote on a single page — the
four-layer case htmlbag's two-pass page assembler is built for. Useful
for verifying that the painters all use the same `flushInserts` order
when several insert types compete for the same page.

## Run

```
glu ../foproc.lua 04-float-mixed.fo out=result.pdf
```

## Result

![first page of result.pdf](firstpage.png)
