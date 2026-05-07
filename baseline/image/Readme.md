# Image

Imports the bundled `ocean.pdf` as a Form XObject via `gofpdi` and
places it on a page. The PDF is embedded as vector content — no
rasterisation, no resolution loss.

## Run

```
go run main.go
```

Produces `out.pdf`.

## Result

![first page of out.pdf](firstpage.png)
