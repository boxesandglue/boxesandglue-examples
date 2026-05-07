# Outline — direct destinations

PDF outline (bookmark) tree with **direct** destination references —
each outline item points to a page object plus an explicit
`(/XYZ left top zoom)` view rectangle.

Compare with `../outlinenamedest/` for the named-destination variant.

## Run

```
go run main.go
```

Produces `out.pdf`.

## Result

![first page of out.pdf](firstpage.png)
