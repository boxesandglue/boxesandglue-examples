# Bookmarks with named destinations

A bookmark tree whose entries point at names such as `chapter-1`. Each
name is mapped to its page and view once, in the `/Names` dictionary
of the catalog, which keeps it in one place when several bookmarks or
links share a target.

The [direct variant](../outlinedirectdest) points at pages instead.

## Run

```
go run .
```

Writes `out.pdf`.

## Result

![first page of the PDF](firstpage.png)
