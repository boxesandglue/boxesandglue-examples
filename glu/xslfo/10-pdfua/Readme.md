# 10 PDF/UA accessibility

A PDF/UA-1 (ISO 14289-1) document. Three settings on `fo:root` turn on
the tagged PDF:

| Source | Effect |
|---|---|
| `xml:lang="en-US"` | PDF `/Lang` in the catalog, default hyphenation language |
| `bg:format="PDF/UA"` | `/MarkInfo /Marked true`, structure tree, `/DisplayDocTitle`, XMP `pdfuaid:part 1`, a structure element for every paragraph, heading and figure |
| `<fo:title>...</fo:title>` | PDF `/Title` (and XMP `dc:title`) |

In the flow, `fo:block role="H1"` to `role="H6"` makes heading
structure elements, and `fo:external-graphic alt="..."` fills the
`/Alt` entry of the Figure. The imported `ocean.pdf` is a Form XObject
with a `/StructParent` entry, so screen readers see one Figure instead
of the untagged content inside the image.

## Run

```
glu ../foproc.lua 10-pdfua.fo out=out.pdf
```

Run this inside the directory. It writes `out.pdf`; the directory
ships a copy as `result.pdf`.

## Verifying

```
pdfinfo result.pdf                    # Title, Tagged: yes
veraPDF --profile PDF/UA-1 result.pdf # full ISO 14289-1 conformance check
```

## Result

![first page of result.pdf](firstpage.png)
