# 08 — Mixed LTR / RTL

English (LTR) and Arabic (RTL) inside the same paragraph, with per-run
`xml:lang`. The bidi algorithm reorders the runs and the typesetter
selects the per-language hyphenation pattern set on the fly:

* English runs use the `en` pattern set
* Arabic runs use a no-op hyphenator (no TeX pattern set exists for
  Arabic — CSS Text 3 §6 says a UA must not hyphenate without
  patterns)
* `hyphenate="false"` on a run opts out of automatic hyphenation
  locally

## Run

```
glu ../foproc.lua 08-mixed-ltr-rtl.fo out=result.pdf
```

## Result

![first page of result.pdf](firstpage.png)
