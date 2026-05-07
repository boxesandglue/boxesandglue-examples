# 10 — PDF/UA accessibility

ISO 14289-1 (PDF/UA-1) showcase. Three top-level metadata items on
`fo:root` activate the tagged-PDF pipeline:

| Source | Effect |
|---|---|
| `xml:lang="en-US"` | PDF `/Lang` catalog entry, hyphenation default |
| `bg:format="PDF/UA"` | `MarkInfo /Marked true`, StructTreeRoot, `/DisplayDocTitle`, XMP `pdfuaid:part 1`, role-mapped element tree |
| `<fo:title>…</fo:title>` | PDF `/Title` (and XMP `dc:title`) |

Inside the flow, `fo:block role="H1..H6"` produces heading structure
elements, `fo:external-graphic alt="…"` populates the Figure `/Alt`
entry, and the imported `ocean.pdf` is wrapped as a Form XObject with
`/StructParent` so screen readers see a single Figure tag instead of
the (untagged) inner content stream.

## Run

```
glu ../foproc.lua 10-pdfua.fo out=result.pdf
```

## Verifying

```
pdfinfo result.pdf                    # /Title, /Lang, Tagged: yes
veraPDF --profile PDF/UA-1 result.pdf # full ISO 14289-1 conformance
```

## Result

![first page of result.pdf](firstpage.png)
