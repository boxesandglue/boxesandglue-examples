# ZUGFeRD invoice

Builds an EN 16931 / ZUGFeRD-conformant electronic invoice as a
PDF/A-3 with the structured invoice XML embedded as an attachment.

The example uses the low-level Lua frontend bindings directly:

| File | Purpose |
|---|---|
| `main.lua` | Sets up the document, colour profile, font family, output filename |
| `document.lua` | Renders the visible invoice layout (logo, address block, item table, totals) |
| `zugferd.lua` | Loads `zugferd.xml` and embeds it as a PDF attachment with the EN 16931 conformance level |
| `zugferd.xml` | Cross-Industry Invoice (CII) XML — the structured side of the invoice |
| `AdobeRGB1998.icc` | Output intent for PDF/A-3 |
| `img/logo.pdf` | Sample company logo |

## Run

```
glu main.lua
```

The result is written as `result.pdf` next to the script. Verify the
EN 16931 attachment with `pdfdetach -list result.pdf`.

## Result

![first page of result.pdf](firstpage.png)
