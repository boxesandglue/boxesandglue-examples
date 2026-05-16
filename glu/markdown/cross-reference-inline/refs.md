---
title: Cross-references with inline anchors
author: glu
papersize: a5
lang: en
css: refs.css
---

# Setup {#setup}

The fundamental result we rely on is
<span id="thm-bw">the Bolzano–Weierstrass theorem</span>, which says
every bounded sequence in ℝ has a convergent subsequence.

We also use the special case
<span id="thm-mvt">the mean value theorem</span> for continuous
functions on closed intervals.

# Application {#application}

The optimisation argument splits into two halves. The first half
appeals to <a class="ref" href="#thm-bw"></a> to extract a convergent
subsequence from the candidate set, then the second half uses
<a class="ref" href="#thm-mvt"></a> to locate the maximiser.

Concretely, the algorithm is well-defined whenever the input space is
bounded — exactly the condition
<a class="ref" href="#thm-bw"></a> needs.

For the proof outline, see also the
<a class="ref" href="#setup"></a> section above.

# A look back

Three cross-reference styles appear in this document:

- inline anchor on a `<span>` carrying the term itself
  (<a class="ref" href="#thm-bw"></a>, captured at character level)
- block anchor on a heading (<a class="ref" href="#application"></a>)
- the anchor's text and the page number both come from CSS, so
  removing or moving a section updates every reference automatically
  on the next render pass.
