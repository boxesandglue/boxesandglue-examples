# Transparency in SVG

A poster drawn as one SVG file: a lake at dusk, with the title standing
behind the mountains and sinking into the fog. Each part uses a
different way to make something transparent, and glu turns all of them
into PDF transparency. Nothing is rasterized, the poster stays vector
art with real text.

| Part | SVG | PDF |
| ---- | --- | --- |
| Fog, faded reflection | `stop-opacity` | A soft mask with a gray gradient |
| Stars, glow of the sun | `fill-opacity` | A constant alpha |
| Reflection | `<g opacity>` | A transparency group |
| Ripples | `stroke-opacity` | A constant alpha for strokes |
| Glass panel | `fill-opacity` and `stroke-opacity` | Separate alphas for fill and stroke |

## How it works

`opacity` on a group is not the same as `fill-opacity` on each of its
shapes:

```svg
<!-- One flat result: the group is painted first, then made transparent. -->
<g opacity=".5"> <polygon .../> <polygon .../> </g>

<!-- Every overlap shows: each shape is transparent on its own. -->
<g fill-opacity=".5"> <polygon .../> <polygon .../> </g>
```

The reflection needs the first form, as the trees overlap. The glow of
the sun uses the second on purpose: the circles add up to the rings
around it.

Stops that differ in opacity let a gradient fade out:

```svg
<linearGradient id="fog0" gradientUnits="userSpaceOnUse" x1="0" y1="252" x2="0" y2="326">
  <stop offset="0" stop-color="#ffd2b0" stop-opacity="0"/>
  <stop offset="1" stop-color="#ffd2b0" stop-opacity=".78"/>
</linearGradient>
```

The order in the file does the rest. The title comes after the first
ridge and before the second one, so the fog of the second ridge covers
its lower half.

PDF/X-3 forbids transparency: the image stays opaque there and glu
writes a warning. PDF/A-3b and PDF/X-4 keep it.

## Run

```bash
glu transparency.html -o out.pdf
```
