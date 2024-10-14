
const bag = require("bag:backend/bag");
const document = require("bag:backend/document");
const node = require("bag:backend/node");
const font = require("bag:backend/font");
const harfbuzz = require("bag:harfbuzz");


const doc = new document.document("out.pdf");

const face = doc.loadFace("../../fonts/crimsonpro/CrimsonPro-Regular.ttf", 0);
const fnt = font.newFont(face, bag.mustSP("12pt"));


const atoms = fnt.shape("A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring which I enjoy with my whole heart. I am alone, and feel the charm of existence in this spot, which was created for the bliss of souls like mine. I am so happy, my dear friend, so absorbed in the exquisite sense of mere tranquil existence, that I neglect my talents.", harfbuzz.features("+liga", "+kern"));

var head, tail;

for (const atom of atoms) {
    var n;
    if (atom.isSpace) {
        n = node.newGlue();
        n.width = fnt.space;
        n.stretch = fnt.spaceStretch;
        n.shrink = fnt.spaceShrink;
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

node.appendLineEndAfter(head,tail)
const ls = new node.linebreakSettings({hSize: 125 * bag.factor, lineHeight: 12 * bag.factor});
ret = node.linebreak(head,ls);
const vl = ret[0]

const p1 = doc.newPage();
p1.width = bag.mustSP("21cm");
p1.height = bag.mustSP("29.7cm");

const onecm = bag.mustSP("1cm");

p1.outputAt(onecm, p1.height - onecm, vl);

p1.shipout();

doc.finish();


