# 11 PDF/UA-2 accessibility

A PDF/UA-2 (ISO 14289-2) document on PDF 2.0. The source has the same
structure as `10-pdfua`, with `bg:format="PDF/UA-2"` on `fo:root`.
This one setting also switches the output to PDF 2.0 and puts the
structure tree in the HTML5 namespace.

| Source | Effect |
|---|---|
| `xml:lang="en-US"` | PDF `/Lang` in the catalog, default hyphenation language |
| `bg:format="PDF/UA-2"` | PDF 2.0 header, `/MarkInfo`, structure tree with a `/Namespaces` array, element tree in the HTML5 namespace, XMP `pdfuaid:part 2` |
| `<fo:title>...</fo:title>` | XMP `dc:title` |

What the output contains:

* a `%PDF-2.0` header and no `/Info` dictionary (deprecated in PDF 2.0;
  the XMP metadata carries the document information)
* `/MarkInfo << /Marked true >>` without `/Suspects` (its default is
  `false`)
* a `/Namespaces` array in the structure tree root that references
  three `/Namespace` objects:
  * `http://www.w3.org/1999/xhtml` (HTML5)
  * `http://iso.org/pdf2/ssn` (PDF 2.0 standard structure namespace)
  * `http://iso.org/pdf/ssn` (PDF 1.7 standard structure namespace)
* structure elements:
  * `/S /Document` in the PDF 2.0 namespace (HTML5 has no matching
    root element)
  * `/S /h1` to `/S /h3`, `/S /p` and `/S /figure` in the HTML5
    namespace
* `<pdfuaid:part>2</pdfuaid:part>` in the XMP metadata

## Run

```
glu ../foproc.lua 11-pdfua2.fo out=out.pdf
```

Run this inside the directory. It writes `out.pdf`; the directory
ships a copy as `result.pdf`.

## Verifying

```
pdfinfo result.pdf                     # PDF version: 2.0, Tagged: yes
veraPDF --profile PDF/UA-2 result.pdf  # full ISO 14289-2 conformance check
```

## Result

![first page of result.pdf](firstpage.png)
