# Absolute positioning

Instead of `RenderPages`, which flows HTML over pages, this example
calls `OutputAt` once for each HTML snippet: a heading, two cards and a
label at the bottom. Each call takes the HTML, a width (here 90mm) and
the x and y coordinates of the snippet's top left corner, with y
measured from the bottom edge of the page. The snippets do not flow
into each other. The CSS is passed as a string to `AddCSS`, and the
document is tagged for PDF/UA (`document.WithPDFUA()`).

To get the PDF, run

    go run .

in this directory. The program writes `out.pdf`.

The result looks like this:

![HTML snippets at fixed positions in PDF](result.png)
