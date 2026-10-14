# Accessible PDF (PDF/UA-1)

`document.New("out.pdf", document.WithPDFUA())` turns on PDF/UA-1 and
structure tagging. PDF/UA requires a title and a language, so `main.go`
sets `d.Title` and `d.Language`. The HTML fragment `chunk.html` (two
headings, paragraphs, a bulleted and a numbered list, a code block)
becomes a tagged PDF with structure elements such as `H1`, `P`, `L`,
`LI` and `Code`.

`structure.html` shows such a structure tree in the browser. Use the
switch at the top right to change between the Content and the
Structure view.

To get the PDF, run

    go run .

in this directory. The program writes `out.pdf`.

The result looks like this:

![Tagged PDF rendered from HTML](result.png)
