# glu examples

Examples for [glu](https://boxesandglue.dev/glu/), the command line
tool of boxes and glue. glu turns Markdown, HTML and Lua scripts into
PDF, and with a Lua walker also XSL-FO and JATS XML. Every example
holds its source, the `result.pdf` it makes and a `firstpage.png`
preview.

The examples are sorted by input format. The [overview](..) one level
up sorts all examples, glu and the others, by topic.

## By input format

### [Markdown](markdown)

Documents written in Markdown, with YAML frontmatter, Lua blocks and
HTML where needed: a scientific paper, a DIN 5008 letter, a ZUGFeRD
invoice, TeX math, a table of contents, tab stops, barcodes, slides.
Most of them have a how-to on the website.

### [HTML](html)

HTML and CSS typeset through htmlbag: multi-column layout, margin
notes, text around images, letterheads and running footers, tables
and lists, right-to-left text, color emoji, MathML. The
[floats](html/floats) subdirectory shows top and bottom floats and
footnotes in five steps.

### [XSL-FO](xslfo)

A Lua walker, `foproc.lua`, turns XSL-FO into HTML and hands it to
htmlbag. Eleven small documents show what it translates, from blocks
and footnotes to floats, images, Arabic and PDF/UA.

### [JATS](jats)

A Lua walker, `jats.lua`, turns a journal article in JATS XML into
HTML, MathML formulas included, and typesets it.

### [Lua interface](lua_interface)

Scripts that build a document with glu's Lua API alone, without
Markdown or HTML: a ZUGFeRD invoice laid out from its XML, and a look
at the text shaper.

## Running an example

Inside the example's directory, run glu on its source file, for
example `glu multi-column.html -o out.pdf`. The Readme of each example
gives the exact command, the Readme of each input format the details.

## Installing glu

Prebuilt binaries: <https://github.com/boxesandglue/glu/releases/latest>.

Homebrew (macOS and Linux):

```
brew install boxesandglue/tap/glu
```

Built from source (needs Go):

```
git clone https://github.com/boxesandglue/glu
cd glu
rake build
```

The [glu documentation](https://boxesandglue.dev/glu/) describes
installation and use in full.
