
const bag = require("bag:backend/bag");
const document = require("bag:backend/document");
const node = require("bag:backend/node");
const font = require("bag:backend/font");
const harfbuzz = require("bag:harfbuzz");


const doc = new document.document("out.pdf");

const face = doc.loadFace("../../../fonts/crimsonpro/CrimsonPro-Regular.ttf", 0);
const fnt = font.newFont(face, bag.mustSP("12pt"));


const atoms = fnt.shape("The quick brown fox jumps on the lazy fish", harfbuzz.features("+liga", "+kern"));

var head, tail;

for (const atom of atoms) {
    var n;
    if (atom.isSpace) {
        n = node.newGlue();
        n.width = 4 * bag.factor;
        n.setretch = 2 * bag.factor;
        n.shrink = 1.33 * bag.factor;
    } else {
        n = node.newGlyph()
        n.width = atom.advance
        n.font = fnt
        n.codepoint = atom.codepoint
        n.components = atom.components
    }
    head = node.insertAfter(head, tail, n)
    tail = n;
}

const hl = node.hpack(head);
const vl = node.vpack(hl);

const p1 = doc.newPage();
p1.width = bag.mustSP("21cm");
p1.height = bag.mustSP("29.7cm");

const onecm = bag.mustSP("1cm");

p1.outputAt(onecm, p1.height - onecm, vl);

p1.shipout();

doc.finish();

