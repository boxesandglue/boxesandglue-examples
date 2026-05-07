# Text shaping

Calls `frontend.shape` directly and prints the shaping result —
glyph IDs, cluster numbers, advance widths, codepoints — to stdout.
There is no PDF output; this example is a sanity check on the
HarfBuzz / boxesandglue text-shaping path.

## Run

```
glu main.lua
```

## Expected output

```
glyph=362 cluster=0 advance=508 codepoint=U+006F original="o"
glyph=304 cluster=1 advance=303 codepoint=U+0066 original="f"
glyph=478 cluster=2 advance=547 codepoint=U+0066 original="fi"
glyph=266 cluster=4 advance=420 codepoint=U+0063 original="c"
glyph=280 cluster=5 advance=450 codepoint=U+0065 original="e"
```

The third row is interesting: input `"f" "i"` (clusters 2 and 3)
shapes to a single ligature glyph (`fi`, cluster 2, advance 547pt
units). HarfBuzz keeps the cluster number of the first input
character and skips the second cluster number entirely, which is how
callers reconstruct character → glyph mapping after ligation.
