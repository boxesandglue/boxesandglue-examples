# ZUGFeRD invoice in Markdown mode

Produces an invoice PDF that complies with **EN 16931 / ZUGFeRD 2 /
Factur-X**, with the structured Cross Industry Invoice XML embedded as
an attachment. The example demonstrates the **companion Lua pattern**
for compliance formats. glu's Markdown mode has no ZUGFeRD-specific
code: all the plumbing (XML attachment, XMP extension schema, output
intent, data extraction) lives in `rechnung.lua` as plain frontend Lua
code.

The same pattern carries over to **XRechnung**, **PEPPOL** or other
compliance formats without changes to glu itself.

The how-to on the website walks through this example step by step:
<https://boxesandglue.dev/glu/howto/zugferd-invoice/>.

## Files

| File | Purpose |
|---|---|
| `rechnung.md` | Visible invoice in Markdown; sets `format: PDF/A-3b` in the frontmatter and uses `{= zugferd.* =}` inline expressions |
| `rechnung.lua` | Companion Lua: parses the XML, exposes a `zugferd` global, registers a `page_init` callback for the output intent, the attachment and the XMP extension |
| `rechnung.css` | Layout stylesheet (letterhead, address block, positions table, totals) |
| `invoice.xml` | ZUGFeRD 2.3.0 Cross Industry Invoice (FeRD sample) |
| `AdobeRGB1998.icc` | Output intent profile for PDF/A-3 |
| `Readme.md` | This file |
| `result.pdf`, `firstpage.png` | Snapshot of the rendered output and a preview of its first page |

## Run

```
glu rechnung.md -o out.pdf
```

This writes `out.pdf` (this directory ships a copy as `result.pdf`).
To verify the ZUGFeRD attachment:

```
pdfdetach -list out.pdf
# 1 embedded files
# 1: factur-x.xml

exiftool -XMP-pdfaid:Part -XMP-fx:ConformanceLevel \
         -XMP-fx:DocumentFileName out.pdf
# Part                : 3
# Conformance Level   : EN 16931
# Document File Name  : factur-x.xml
```

## How the pattern works

glu loads the Lua file that matches the Markdown file name
(`rechnung.lua` for `rechnung.md`) automatically. It runs as a
top-level script *before* the `{= … =}` inline expressions and the
`{lua}` blocks in the Markdown body are evaluated, which makes it the
right place for data preparation.

**Three building blocks:**

1. **XML parsing** (top level of `rechnung.lua`): `cxpath` opens
   `invoice.xml`, extracts fields and fills the `zugferd` global with
   `id`, `date`, `currency`, `seller.*`, `buyer.*`, `lines[i].*`,
   `line_total`, `tax_total`, `total` and `payment_terms`. All values
   stay **strings**, so there is no float rounding drift, and number
   formatting is left to the author.

2. **Inline expressions in the body**: `{= zugferd.id =}`,
   `{= zugferd.buyer.name =}` and so on. A small `{lua}` block builds
   the positions table from `zugferd.lines` and returns it as a
   Markdown pipe table.

3. **PDF compliance plumbing** (`page_init` callback): when the first
   page is initialized, the document is available, and the callback
   calls `load_colorprofile`, `attach_file` and `add_xmp_extension`.
   An `initialized` guard makes sure this runs exactly once.
   `format: PDF/A-3b` is set in the Markdown frontmatter (a generic
   glu key, not specific to ZUGFeRD).

## Why companion Lua instead of built-in support?

- ZUGFeRD is a **domain-specific** compliance requirement (invoices
  with embedded structured XML and schema validation), and glu is a
  **general-purpose typesetting tool**. If glu supported ZUGFeRD in its
  core, the next request would be XRechnung, then PEPPOL, then
  BSI TR-RESISCAN. The list has no natural end.
- Companion Lua is glu's established extension mechanism. It is stable
  across versions, testable and easy to inspect, and the author keeps
  full control. When the ZUGFeRD specification introduces a new
  property, the author changes a few lines of `rechnung.lua`. No glu
  release is needed.

## Adapting for your own invoice

1. Replace `invoice.xml` with your CII XML (or generate it from your
   billing system).
2. Adjust `rechnung.md` to match your layout.
3. `rechnung.lua` reads the fields the visible invoice shows: invoice
   number, date, currency, seller and buyer address and VAT ID, the
   line items, the totals and the payment terms. If your layout shows
   more, such as the amount due or the invoice type code, add the
   XPath expressions for them.
4. Replace `AdobeRGB1998.icc` with an sRGB or other ICC profile if
   your workflow requires it.

## Result

![first page of result.pdf](firstpage.png)
