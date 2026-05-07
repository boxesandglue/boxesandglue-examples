# 09 — Soft hyphens

CSS Text 3 `hyphens` modes side by side, controlled by the FO
`hyphenate` property:

| `hyphenate=` | CSS `hyphens` | Behaviour |
|---|---|---|
| `true`   | `auto`   | Pattern-based hyphenation + soft-hyphens |
| `manual` | `manual` | Only U+00AD soft-hyphens, no pattern lookup |
| `false`  | `none`   | Never break |

Soft hyphens are written as the XML numeric character reference
`&#xAD;`. boxesandglue routes them through a discretionary node so
they only appear when the line breaker chooses to break there.

## Run

```
glu ../foproc.lua 09-soft-hyphen.fo out=result.pdf
```

## Result

![first page of result.pdf](firstpage.png)
