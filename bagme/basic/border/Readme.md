# Border and background

Renders the same kind of HTML fragment as the
[basic rendering example](../simple), but the second paragraph has the
class `border`. `styles.css` gives it a 1pt solid border with rounded
corners (`border-radius: 5pt`), an `antiquewhite` background and a
padding of 1rem.

To get the PDF, run

    go run .

in this directory. The program writes `out.pdf`.

The result looks like this:

![Paragraph with border and background in PDF](result.png)
