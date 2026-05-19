# Accessible report (PDF/UA-2)

A minimal Markdown source that demonstrates the PDF/UA-2 output
of glu's Markdown pipeline (ISO 14289-2:2024 on PDF 2.0). The
only switch is the `format: PDF/UA-2` line in the YAML frontmatter.

```yaml
---
title: Accessible Quarterly Report
author: Communications Team
format: PDF/UA-2
lang: en
---
```

Standard CommonMark below the frontmatter renders into a fully
tagged PDF tree: headings, a table with `thead`/`tbody`/`th`/`td`,
an unordered list, an inline code span, and a heading-driven
outline whose `/Dest` entries are structure destinations
(ISO 14289-2 §8.8). No CSS or Lua is needed.

## Run

```
glu accessible-report.md
```

## Verifying

```
pdfinfo accessible-report.pdf           # PDF version: 2.0, Tagged: yes
verapdf --flavour ua2 accessible-report.pdf
```

veraPDF reports `isCompliant=true` (1723 rules, 7905 checks, 0
failed). The same input rendered with `format: PDF/UA` (or
`PDF/UA-1`) produces a PDF/UA-1 PDF on PDF 1.7 with the
capitalised PDF Standard Structure Namespace role names.

## What you get

- `%PDF-2.0` header. The `/Info` dictionary is omitted (PDF 2.0
  uses XMP instead).
- `MarkInfo << /Marked true >>` and `/DisplayDocTitle true`.
- XMP carries `pdfuaid:part = 2` and `pdfuaid:rev = 2024`.
- `StructTreeRoot` has a `/Namespaces` array referencing two
  `/Namespace` objects: HTML5
  (`http://www.w3.org/1999/xhtml`) with a complete `RoleMapNS`
  and the PDF Standard Structure namespace
  (`http://iso.org/pdf2/ssn`, plus `http://iso.org/pdf/ssn` for
  the few PDF 1.7-only roles such as `Code`).
- Structure elements use lowercase HTML5 role names where they
  exist (`p`, `h1`–`h6`, `figure`, `table`, `tr`, `td`, `li`,
  `code`, …).
- The outline's `/Dest` entries point to structure elements, not
  to pages.

## Result

![first page of result.pdf](firstpage.png)
