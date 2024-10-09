baseline = require("bag:baseline")


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



img = pdf.loadImageFile("../../../images/ocean.pdf")


var st = pdf.newObject();

var scale = 0.45;

st.data.writeString("q {0} 0 0 {0} 10 10 cm {1} Do Q\n".format(scale, img.internalName()));
st.save()



page = pdf.addPage(st, 0);
page.width = 400;
page.height = 300;
page.images.push(img);


pdf.finish()



