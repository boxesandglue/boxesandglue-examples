
const bag = require("bag:backend/bag");
const document = require("bag:backend/document");
const node = require("bag:backend/node");
const font = require("bag:backend/font");
const image = require("bag:backend/image");


const doc = new document.document("out.pdf");

const img = doc.pdfWriter.loadImageFile("../../../images/ocean.pdf")

i = doc.createImage(img,1,"/MediaBox")

imageNode = node.newImage()
imageNode.img = i
imageNode.width = bag.mustSP("4cm")
imageNode.height = bag.mustSP("4cm")


const hl = node.hpack(imageNode);
const vl = node.vpack(hl);

const p1 = doc.newPage();
p1.width = bag.mustSP("21cm");
p1.height = bag.mustSP("29.7cm");

const onecm = bag.mustSP("1cm");

p1.outputAt(onecm, p1.height - onecm, vl);

p1.shipout();

doc.finish();

