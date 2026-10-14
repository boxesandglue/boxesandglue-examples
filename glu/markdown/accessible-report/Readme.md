# Accessible report (PDF/UA-2)

A minimal Markdown source that shows the PDF/UA-2 output of glu's
Markdown pipeline (ISO 14289-2:2024 on PDF 2.0). The only switch is
the `format: PDF/UA-2` line in the YAML frontmatter. The
[how-to](https://boxesandglue.dev/glu/howto/accessible-report/) walks
through it step by step.

```yaml
---
title: Accessible Quarterly Report
author: Communications Team
format: PDF/UA-2
lang: en
---
```

Standard CommonMark below the frontmatter renders into a fully
tagged PDF: headings, a table with `thead`/`tbody`/`th`/`td`, an
unordered list, inline code spans, and a heading-driven outline whose
`/Dest` entries are structure destinations (ISO 14289-2 §8.8). No CSS
or Lua is needed.

## Run

```
glu accessible-report.md -o out.pdf
```

## Verifying

```
pdfinfo out.pdf           # PDF version: 2.0, Tagged: yes
verapdf --flavour ua2 out.pdf
```

veraPDF reports `isCompliant=true` with no failed rules or checks.
The same input rendered with `format: PDF/UA` (or `PDF/UA-1`)
produces a PDF/UA-1 file on PDF 1.7 with the capitalized role names
of the PDF standard structure namespace.

## What you get

- A `%PDF-2.0` header. The `/Info` dictionary is omitted (PDF 2.0
  uses XMP instead).
- `MarkInfo << /Marked true >>` and `/DisplayDocTitle true`.
- The XMP metadata carries `pdfuaid:part = 2` and
  `pdfuaid:rev = 2024`.
- `StructTreeRoot` has a `/Namespaces` array with three `/Namespace`
  objects: HTML5 (`http://www.w3.org/1999/xhtml`) with a complete
  `RoleMapNS`, the PDF 2.0 standard structure namespace
  (`http://iso.org/pdf2/ssn`), and the PDF 1.7 one
  (`http://iso.org/pdf/ssn`) for the few roles that only exist there,
  such as `Code`.
- Structure elements use lowercase HTML5 role names where they exist
  (`p`, `h1` to `h6`, `figure`, `table`, `tr`, `td`, `li`, `code`,
  …).
- The outline's `/Dest` entries point to structure elements, not to
  pages.

## Result

![first page of result.pdf](firstpage.png)
