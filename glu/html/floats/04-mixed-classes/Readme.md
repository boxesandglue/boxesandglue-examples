# 04 — All four insert classes

All four insert classes coexisting on a single page: top-float, body,
bottom-float, footnote. The `flushInserts` painter runs in this order
on each page:

```
1. Top-float stack       (yStart, going down)
2. Buffered body         (just below the float zone)
3. Bottom-float stack    (above the footnote zone)
4. Footnote stack        (yLimit, going up; separator rule above)
```

## Run

```
glu 04-mixed-classes.html
```

(produces `04-mixed-classes.pdf`; this directory ships a copy as
`result.pdf`.)

## Result

![first page of result.pdf](firstpage.png)
