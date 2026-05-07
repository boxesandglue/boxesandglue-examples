# Outline — named destinations

PDF outline (bookmark) tree with **named** destination references —
outline items point to symbolic names (e.g. `chapter-1`); the actual
page+view tuple is registered once in the catalog's `/Names`
dictionary. Cleaner indirection when several outlines / links share
the same target.

Compare with `../outlinedirectdest/` for the direct-destination
variant.

## Run

```
go run main.go
```

Produces `out.pdf`.

## Result

![first page of out.pdf](firstpage.png)
