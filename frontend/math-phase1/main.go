// math-phase1 — a minimal demo of the OpenType MATH engine added in
// boxesandglue/frontend/math. Builds the canonical phase-1 showcase
//
//	x_i + ½ √(a² + b²)
//
// directly via the Go API (no MathML, no Lua — those are later phases),
// drops one inline-math result on a page, and writes a PDF.
//
// Build & run:
//
//	go run main.go
//	open out.pdf
//
// The Latin Modern Math font must be next to this file (latinmodern-math.otf).
// It is the de-facto reference OT-MATH font; see
// boxesandglue/frontend/math/testdata/README.md for download sources.
package main

import (
	"fmt"
	"log"
	"time"

	"github.com/boxesandglue/boxesandglue/backend/bag"
	"github.com/boxesandglue/boxesandglue/backend/font"
	"github.com/boxesandglue/boxesandglue/backend/node"
	"github.com/boxesandglue/boxesandglue/frontend"
	"github.com/boxesandglue/boxesandglue/frontend/math"
	"github.com/boxesandglue/textshape/ot"
)

func run() error {
	f, err := frontend.New("out.pdf")
	if err != nil {
		return err
	}
	f.Doc.Title = "OpenType MATH phase 1 demo"
	if f.Doc.DefaultLanguage, err = frontend.GetLanguage("en"); err != nil {
		return err
	}

	// Load Latin Modern Math. We go straight through frontend.LoadFace so
	// the PDF writer registers the face for embedding, then wrap it in a
	// *font.Font at our desired body size — that's the surface the math
	// engine consumes.
	face, err := f.LoadFace(&frontend.FontSource{Location: "latinmodern-math.otf"})
	if err != nil {
		return fmt.Errorf("LoadFace: %w (see testdata/README.md for the font)", err)
	}
	mathFont := font.NewFont(face, bag.MustSP("14pt"))

	// Resolve the glyph IDs we need. The text shaper does this for us — we
	// just hand it the rune and pick the first atom out of the result.
	// (A future phase will offer a higher-level "math character" API.)
	gid := func(r rune) ot.GlyphID {
		atoms := mathFont.Shape(string(r), nil, nil)
		if len(atoms) == 0 {
			log.Fatalf("font has no glyph for %q", string(r))
		}
		return ot.GlyphID(atoms[0].Codepoint)
	}

	// TeX-style math italic: variables (a, b, x, n, k, i) are taken from the
	// Mathematical Italic block (U+1D44E ff) instead of plain ASCII so they
	// render in the italic alphabet LaTeX users expect for math variables.
	// Numbers, operators and brackets stay ASCII (TeX renders those upright).
	xGid := gid('𝑥')      // U+1D465
	iGid := gid('𝑖')      // U+1D456
	plusGid := gid('+')
	oneGid := gid('1')
	twoGid := gid('2')
	radGid := gid('√')
	aGid := gid('𝑎')      // U+1D44E
	bGid := gid('𝑏')      // U+1D44F
	sumGid := gid('∑')
	nGid := gid('𝑛')      // U+1D45B
	eqGid := gid('=')
	zeroGid := gid('0')
	kGid := gid('𝑘')      // U+1D458
	lparenGid := gid('(')
	rparenGid := gid(')')

	// Inline formula 1: x_i + (1/2) √(a² + b²)
	expr1 := []math.MathItem{
		math.Ord(xGid).WithSubGlyph(iGid),
		math.Bin(plusGid),
		math.Frac(
			[]math.MathItem{math.Ord(oneGid)},
			[]math.MathItem{math.Ord(twoGid)},
		),
		math.Sqrt(radGid,
			math.Ord(aGid).WithSupGlyph(twoGid),
			math.Bin(plusGid),
			math.Ord(bGid).WithSupGlyph(twoGid),
		),
	}
	hl1, err := math.InlineMath(mathFont, expr1...)
	if err != nil {
		return fmt.Errorf("InlineMath: %w", err)
	}

	// Display formula 2: ∑_{k=0}^{n} k²  — exercises the big-op variant
	// path. In DisplayStyle the engine picks a larger ∑ glyph (or assembly)
	// via MathVariants and centers it on the math axis.
	expr2 := []math.MathItem{
		math.Op(sumGid).
			WithSub(math.Ord(kGid), math.Rel(eqGid), math.Ord(zeroGid)).
			WithSupGlyph(nGid),
		math.Ord(kGid).WithSupGlyph(twoGid),
	}
	hl2, err := math.DisplayMath(mathFont, expr2...)
	if err != nil {
		return fmt.Errorf("DisplayMath: %w", err)
	}

	// Formula 3a: ( a/b )  in DisplayMath — spec-default LMM display shift.
	frac1 := math.Frac(
		[]math.MathItem{math.Ord(aGid)},
		[]math.MathItem{math.Ord(bGid)},
	)
	frac1.LeftDelim = lparenGid
	frac1.RightDelim = rparenGid
	hl3, err := math.DisplayMath(mathFont, frac1)
	if err != nil {
		return fmt.Errorf("DisplayMath frac: %w", err)
	}

	// Formula 3b: ( a/b )  in InlineMath (TextStyle) — tighter shift,
	// good comparison for the user who feels 3a's 'a' is "too high".
	frac2 := math.Frac(
		[]math.MathItem{math.Ord(aGid)},
		[]math.MathItem{math.Ord(bGid)},
	)
	frac2.LeftDelim = lparenGid
	frac2.RightDelim = rparenGid
	hl4, err := math.InlineMath(mathFont, frac2)
	if err != nil {
		return fmt.Errorf("InlineMath frac: %w", err)
	}

	page := f.Doc.NewPage()
	page.OutputAt(bag.MustSP("2cm"), bag.MustSP("25cm"), node.Vpack(hl1))
	page.OutputAt(bag.MustSP("2cm"), bag.MustSP("22cm"), node.Vpack(hl2))
	page.OutputAt(bag.MustSP("2cm"), bag.MustSP("18cm"), node.Vpack(hl3))
	page.OutputAt(bag.MustSP("6cm"), bag.MustSP("18cm"), node.Vpack(hl4))
	page.Shipout()
	return f.Doc.Finish()
}

func main() {
	t0 := time.Now()
	if err := run(); err != nil {
		log.Fatal(err)
	}
	fmt.Printf("finished in %s — wrote out.pdf\n", time.Since(t0))
}
