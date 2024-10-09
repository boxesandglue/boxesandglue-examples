
bag = require("bag:backend/bag")
fe = require("bag:frontend")



const f = fe.new("out.pdf")

const str = `In olden times when wishing still helped one, there lived a king whose
daughters were all beautiful; and the youngest was so beautiful that the sun itself,
which has seen so much, was astonished whenever it shone in her face.
Close by the king’s castle lay a great dark forest, and under an old lime-tree in the
forest was a well, and when the day was very warm, the king’s child went out into the
forest and sat down by the side of the cool fountain; and when she was bored she
took a golden ball, and threw it up on high and caught it; and this ball was her
favorite plaything.`.replace(/\s+/g, ' ').trim()

ff = f.newFontFamily("text")
ff.addMember(fe.fontSource("../../fonts/crimsonpro/CrimsonPro-Bold.ttf"), fe.fontWeight700, fe.fontStyleNormal)
ff.addMember(fe.fontSource("../../fonts/crimsonpro/CrimsonPro-Regular.ttf"), fe.fontWeight400, fe.fontStyleNormal)
const para = fe.newText()

para.settings[fe.settingSize] = 12 * bag.factor
para.items.push(str);

ret = f.formatParagraph(para, bag.mustSP("125pt"), fe.leading(14 * bag.factor), fe.family(ff))
p = f.doc.newPage()
p.outputAt(bag.mustSP("1cm"), bag.mustSP("26cm"), ret[0])
p.shipout()
f.doc.finish()



