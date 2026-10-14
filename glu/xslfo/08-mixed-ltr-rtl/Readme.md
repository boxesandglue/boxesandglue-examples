# 08 Mixed left to right and right to left

English and Arabic inside the same paragraph, with `xml:lang` on each
run. Each paragraph takes its direction from its first strong
character, and the bidi algorithm orders the runs within it. The
hyphenation patterns switch with the language of each run:

* English runs use the English patterns.
* Arabic runs are not hyphenated. There are no TeX hyphenation
  patterns for Arabic, and CSS Text 3 §6 allows automatic hyphenation
  only where patterns exist.
* `hyphenate="false"` on a run turns off automatic hyphenation for that
  run.

## Run

```
glu ../foproc.lua 08-mixed-ltr-rtl.fo out=out.pdf
```

Run this inside the directory. It writes `out.pdf`; the directory
ships a copy as `result.pdf`.

## Result

![first page of result.pdf](firstpage.png)
