# 07 Arabic, right to left

Arabic blocks set in Amiri, which is registered with
`fo:declarations/bg:font-face`. The walker sets
`unicode-bidi: plaintext` on the body, so each paragraph takes its
direction from its first strong character, and the Arabic paragraphs
run right to left. The `.fo` file needs no direction property. Arabic
shaping (initial, medial, final and isolated forms) happens when the
paragraph is set.

## Run

```
glu ../foproc.lua 07-rtl-arabic.fo out=out.pdf
```

Run this inside the directory. It writes `out.pdf`; the directory
ships a copy as `result.pdf`.

## Result

![first page of result.pdf](firstpage.png)
