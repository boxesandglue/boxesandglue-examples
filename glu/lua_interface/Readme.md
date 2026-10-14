# Lua interface examples

Lua scripts that build a document by calling glu's Lua API directly,
with no Markdown or HTML in front. This is the way to go when the
document needs full control: a page layout of its own, text generated
by a program, or structured data turned into a PDF.

## Examples

Description | Preview
--- | ---
[Text shaping](textshape): calls the shaper directly and prints glyph, cluster, advance and codepoint of every glyph to the console; makes no PDF | <code>glyph=362 cluster=0 …</code>
[ZUGFeRD invoice](zugferdinvoice): an EN 16931 / ZUGFeRD 2 invoice as PDF/A-3 with the Cross Industry Invoice XML attached, laid out from the XML with XPath | <a href="zugferdinvoice"><img src="zugferdinvoice/firstpage.png" width="200"></a>

## Running an example

Inside the example's directory, run glu on the script:

```bash
glu main.lua
```

Arguments after the script name go to the script in `arg`. The ZUGFeRD
example takes the name of the PDF:

```bash
glu main.lua out.pdf
```

Options of glu itself, such as `--loglevel`, come before the script
name.

## The Lua modules

Module | Purpose
--- | ---
`glu` | The top level, with `glu.frontend`, `glu.node` and `glu.font`
`glu.frontend` | Documents, pages, paragraphs, tables, fonts and links
`glu.node` | Nodes: glyphs, boxes, glue, kerns and rules
`glu.font` | Loading fonts
`glu.pdf` | The low-level PDF writer
`glu.htmlbag` | Typesetting a piece of HTML into the current document
`glu.textshape` | The text shaper
`glu.json` | Reading and writing JSON
`glu.log` | Logging to glu's log
`xml.cxpath` | XPath queries on XML; the ZUGFeRD example reads its data with it
`hobby` | MetaPost-style curves

The directory `glu/types/` in the glu repository holds LuaCATS type
definitions. A Lua language server pointed at it offers completion and
documentation while typing.

## Callbacks

`glu.frontend.add_callback(event, fn)` registers a function for one of
these events:

Event | When
--- | ---
`document_start` | after the companion `.lua` file is loaded, before the aux file is read
`content_ready` | after `_aux` and `_toc` are set, before the Lua blocks run
`page_init` | for each new page
`pre_shipout` | for each page before it goes to the PDF
`post_element` | after each block or inline element
`document_end` | at the end of the document

`glu --help` shows the same list.

## Aux file

For Markdown and HTML, glu keeps an aux file, `<input>-aux.json`, with
cross references, the table of contents and whatever Lua stores between
runs, and runs the document again until it no longer changes. A Lua
script handles this itself.

The Lua API is described in the
[glu documentation](https://boxesandglue.dev/glu/).
