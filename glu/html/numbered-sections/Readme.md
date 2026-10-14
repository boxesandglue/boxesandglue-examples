# Numbered sections (Skatordnung style)

Reproduces the classic hanging-indent look of legal codes and rule
books: every paragraph (and every heading) has its section number in
a fixed left gutter, while the body text is justified in a flush
column to the right.

The layout is a plain two-column `<table>`: the left cell holds the
number, the right cell holds the prose. There are no special CSS
constructs (no flex, no negative `text-indent`):

- `<colgroup>` sets the gutter to 50pt and lets the body cell take
  the rest of the page width.
- `vertical-align: top` on the cells keeps the number on the first
  body line. Without it, cells default to vertical centering, which
  moves the number to the middle of a multi-line paragraph.
- `text-align: justify` on the body cell and `hyphens: auto` on the
  `<body>` (inherited by the cells) give the justified look with
  German hyphenation.
- Heading variants add a second class to the body cell
  (`.chapter-title`, `.section-title`). `td.chapter-title` and
  `td.body` have the same specificity, so the rule that comes later in
  the style sheet wins and no `!important` is needed.

## Run

```
glu numbered-sections.html -o out.pdf
```

This produces `out.pdf`. The directory ships a copy as `result.pdf`
and a rendered preview as `firstpage.png`.

## Result

![first page of result.pdf](firstpage.png)
