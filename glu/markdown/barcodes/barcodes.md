---
title: Barcode Examples
lang: en
---

# Barcodes in glu

glu can generate barcodes as vector graphics directly in the PDF.

## EAN-13

<barcode type="ean13" value="4006381333931" width="4cm" height="2cm"/>

## Code 128

<barcode type="code128" value="ABC-12345" width="5cm" height="1.5cm"/>

## QR Code

<barcode type="qr" value="https://boxesandglue.dev" width="3cm"/>

QR code with high error correction:

<barcode type="qr" value="https://boxesandglue.dev" width="3cm" eclevel="H"/>
