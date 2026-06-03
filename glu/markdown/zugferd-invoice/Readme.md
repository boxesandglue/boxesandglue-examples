# ZUGFeRD invoice in Markdown mode

Produces an **EN 16931 / ZUGFeRD 2 / Factur-X**-compliant invoice PDF
with the structured Cross-Industry-Invoice XML embedded as an
attachment. Demonstrates the **companion-Lua pattern** for compliance
formats: glu's Markdown mode has no ZUGFeRD-specific code — all the
plumbing (XML attachment, XMP extension schema, output intent, data
extraction) lives in `rechnung.lua` as plain frontend-Lua code.

The same pattern adapts cleanly to **XRechnung**, **PEPPOL**, **DIN
5008** or any other compliance format — no changes to glu's core
needed.

## Files

| File | Purpose |
|---|---|
| `rechnung.md` | Visible invoice in Markdown; sets `format: PDF/A-3b` via frontmatter, uses `{= zugferd.* =}` inline expressions |
| `rechnung.lua` | Companion Lua: parses the XML, exposes a `zugferd` global, registers a `page_init` callback for output intent + attachment + XMP extension |
| `rechnung.css` | Layout stylesheet (letterhead, address block, positions table, totals) |
| `invoice.xml` | ZUGFeRD 2.3.0 Cross-Industry Invoice (FeRD sample) |
| `AdobeRGB1998.icc` | Output intent profile for PDF/A-3 |
| `Readme.md` | This file |
| `result.pdf`, `firstpage.png` | Static snapshot artefacts |

## Run

```
glu rechnung.md
```

Output: `rechnung.pdf` next to the script. Verify the ZUGFeRD
attachment:

```
pdfdetach -list rechnung.pdf
# 1 embedded files
# 1: factur-x.xml

exiftool -XMP-pdfaid:Part -XMP-zf:ConformanceLevel \
         -XMP-zf:DocumentFileName rechnung.pdf
# Part                : 3
# Conformance Level   : EN 16931
# Document File Name  : factur-x.xml
```

## How the pattern works

glu auto-loads the Lua file matching the Markdown stem
(`rechnung.lua` for `rechnung.md`). It runs as a top-level script
*before* `{= … =}` inline expressions or `{lua}` blocks in the
Markdown body are evaluated — perfect for data preparation.

**Three building blocks:**

1. **XML parsing** (top-level in `rechnung.lua`): `cxpath` opens
   `invoice.xml`, extracts fields and populates the `zugferd` global
   with `id`, `date`, `currency`, `seller.*`, `buyer.*`,
   `lines[i].*`, `total`, `tax_total`, `payment_terms` and so on. All
   values stay as **strings** — no float rounding drift, locale
   formatting left to the author.

2. **Inline expressions in the body**: `{= zugferd.id =}`,
   `{= zugferd.buyer.name =}` etc. The positions table is built in a
   small `{lua}` block from `zugferd.lines` and returned as a
   Markdown pipe table.

3. **PDF compliance plumbing** (`page_init` callback): on the first
   page init the `frontend.Document` is available and we can call
   `load_colorprofile` + `attach_file` + `add_xmp_extension`. An
   `initialized` guard makes sure this runs exactly once.
   `format: PDF/A-3b` is set via the Markdown frontmatter (a generic
   glu key, not ZUGFeRD-specific).

## Why companion Lua instead of built-in?

- ZUGFeRD is a **domain-specific** compliance requirement (invoices
  with embedded structured XML + schema validation). glu is a
  **horizontal typesetting tool**. If glu supported ZUGFeRD in its
  core, the next request would be "XRechnung", then "PEPPOL", then
  "BSI TR-RESISCAN" — the list has no natural end.
- Companion Lua is glu's established extension mechanism. It is
  version-stable, testable, hand-inspectable, and the author has full
  control. When the ZUGFeRD spec introduces a new property tomorrow,
  the author updates 5 lines of `rechnung.lua` — no glu release
  needed.
- If a plugin architecture later turns out to be worthwhile (when
  3-5 unrelated companion-Lua setups for similar tasks emerge in
  practice), companion Lua is the proto-phase from which the plugin
  API can be derived from real use.

## Adapting for your own invoice

1. Replace `invoice.xml` with your CII XML (or generate it from your
   billing system)
2. Adjust `rechnung.md` to match your layout
3. `rechnung.lua` does **not** need to change — the XPath mappings
   cover every EN 16931 mandatory field
4. Replace `AdobeRGB1998.icc` with an sRGB or other ICC profile if
   your workflow requires it

## Result

![first page of result.pdf](firstpage.png)
