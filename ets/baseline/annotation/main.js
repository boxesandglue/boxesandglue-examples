baseline = require("bag:baseline")
harfbuzz = require("bag:harfbuzz")

String.prototype.format = function() {
  var args = arguments;
  return this.replace(/{(\d+)}/g, function(match, number) {
    return typeof args[number] != 'undefined'
      ? args[number]
      : match
    ;
  });
};

var pdf = baseline.new("out.pdf")
var buf = harfbuzz.newBuffer();
face = pdf.loadFace("../../../fonts/crimsonpro/CrimsonPro-Regular.ttf", 0);

const text = "boxesandglue.dev";

buf.addRunes(toRunes(text),0,-1);
buf.guessSegmentProperties()
buf.shape(face.harfbuzzFont, harfbuzz.features("+liga","+kern"))

const codepoints = [];
const arr = ["BT {0} 12 Tf 10 100 Td <".format(face.internalName())];

for (const element of buf.info) {
  codepoints.push(element.glyph)
  arr.push((element.glyph).toString(16).padStart(4, '0'));
}
arr.push("> Tj ET")

face.registerChars(codepoints)
var st = pdf.newObject();
st.data.writeString(arr.join(""))



page = pdf.addPage(st, 0);
page.width = 400;
page.height = 300;
page.faces.push(face)

annot = baseline.annotation()
annot.subtype = "Link";
annot.action = "<</Type/Action/S/URI/URI (https://boxesandglue.dev)>>";
annot.rect = [10, 98, 98, 110]

page.annotations.push(annot)

pdf.finish()



