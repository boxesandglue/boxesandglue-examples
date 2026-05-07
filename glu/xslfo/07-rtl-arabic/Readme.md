# 07 — Arabic / RTL

Arabic-only blocks set in Amiri (registered through
`fo:declarations/bg:font-face`). RTL reordering and Arabic shaping
(initial / medial / final / isolated forms) run automatically when
boxesandglue's paragraph builder sees Arabic codepoints — neither
`dir="rtl"` nor a CSS `direction` declaration is required.

## Run

```
glu ../foproc.lua 07-rtl-arabic.fo out=result.pdf
```

## Result

![first page of result.pdf](firstpage.png)
