# Font

Loads a font and writes a single line of text via `baseline-pdf`'s
font subsystem — no frontend layer, no paragraph builder. Useful for
seeing what the lowest level of the font pipeline looks like.

## Run

```
go run main.go
```

Produces `out.pdf`.

## Result

![first page of out.pdf](firstpage.png)
