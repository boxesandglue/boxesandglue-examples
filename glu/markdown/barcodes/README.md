# Barcodes Example

This example shows how to generate barcodes in glu using the `<barcode>` HTML element. All three supported barcode types are demonstrated: EAN-13, Code 128, and QR code.

## Prerequisites

Install glu using one of these methods:

**Homebrew** (macOS / Linux):

```
brew install boxesandglue/tap/glu
```

**Pre-built binaries** (no Go required):

Download the latest release from <https://github.com/boxesandglue/glu/releases/latest>.

See <https://boxesandglue.dev/glu/> for full installation instructions.

## Running

```
glu barcodes.md
```

This produces `barcodes.pdf`.

## Files

| File | Purpose |
|------|---------|
| `barcodes.md` | Markdown file with `<barcode>` elements for EAN-13, Code 128, and QR codes |

## Barcode types

| Type | Example |
|------|---------|
| EAN-13 | `<barcode type="ean13" value="4006381333931" width="4cm" height="2cm"/>` |
| Code 128 | `<barcode type="code128" value="ABC-12345" width="5cm" height="1.5cm"/>` |
| QR Code | `<barcode type="qr" value="https://example.com" width="3cm" eclevel="H"/>` |

See the [glu documentation](https://boxesandglue.dev/glu/html/#barcodes) for the full attribute reference.
