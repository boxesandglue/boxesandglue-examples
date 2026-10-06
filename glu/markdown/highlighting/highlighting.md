---
title: Highlighting text
lang: en
css: highlighting.css
---

# Marking up a draft

A reviewer reads a draft with a highlighter and a red pen. Everything
on this page is plain Markdown with a few classes on spans; the colors
and lines come from the stylesheet.

## The highlighter

The committee met on Tuesday and [agreed to move the launch to the
first week of March, subject to the results of the final test
run]{.mark}. [The budget stays as planned.]{.mark .green} The
highlight follows the text from one line to the next and covers the
spaces between the words, and a code span such as [the setting
`launch_date`]{.mark} sits inside the same band.

## The red pen

The report ~~will be~~ [is]{.ins} due on Friday, and the figures in
the appendix ~~has~~ [have]{.ins} to be checked again. Please look at
the word [recieve]{.spell} in the second paragraph, and note that
[this claim needs a source]{.query}.

An underline ends where the text ends: [a correction that runs to the
end of a line and on to the next]{.query} is not drawn out into the
margin, while the spaces between its words are underlined.
