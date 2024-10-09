pdf = require("bag:baseline")

pw = pdf.new("out.pdf")

pw.defaultPageWidth = 400;
pw.defaultPageHeight = 500;


stream = pw.newObject();
stream.data.writeString("10 10 280 480 re s");
stream.save();

p = pw.addPage(stream, 0)

d = pdf.nameDest();
d.x = 0;
d.Y = 500;
d.pageObjectnumber = p.objnum
d.name = "A destination"

pw.nameDestinations[d.name] = d;

o = pdf.outline();
o.title = "A bookmark";
o.open = true;
o.dest = pdf.serialize(pdf.string("A destination"));

pw.outlines.push(o);

pw.finish();


