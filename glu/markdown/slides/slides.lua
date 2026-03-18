-- Companion Lua file for slides.md
local frontend = require("glu.frontend")
local h = require("hobby")

math.randomseed(os.time())

local randomamount = 10

local function randomized(point, amount)
    local dy = math.random(-amount, amount)
    return h.point(point.x, point.y + dy)
end

-- Accent line at the top of each content slide, drawn with hobby/MetaPost
frontend.add_callback("page_init", "accent_line", function(doc, page, pagenum, pageinfo)
    if pagenum == 1 then return end

    local ml = 0
    local w = page.width.pt
    local sw = 5
    local mt = -1 * pageinfo.margin_top * 0.8

    -- Start/end beyond page edges so the line always reaches the margins
    local line = h.path()
        :moveto(0, 0)
        :lineto(w, 0)
        :lineto(randomized(h.point(w + randomamount, mt.pt), randomamount))
        :dir(-180)
        :indir(180)
        :curveto(randomized(h.point(-randomamount, mt.pt), randomamount))
        :cycle()
        :stroke("#FF95383A")
        :fill("#FF95383A")
        :strokewidth(sw)
        :linecap("square")
        :build()

    local vbh = 2 * (randomamount + sw)
    local svgstr = h.svg():viewbox(0, -vbh/2, w, vbh):add(line):tostring()
    local svgdoc = frontend.parse_svg_string(svgstr)
    -- height=0: proportional to width, preserving aspect ratio automatically
    local svgnode = doc:create_svg_node(svgdoc, page.width)
    page:output_at(ml, page.height + svgnode.height / 2, svgnode)

    -- Bottom accent line
    local mb = pageinfo.margin_bottom
    local bottom_line = h.path()
        :moveto(0, 0)
        :lineto(w, 0)
        :lineto(randomized(h.point(w + randomamount, mb.pt), randomamount))
        :lineto(randomized(h.point(-randomamount, mb.pt), randomamount))
        :cycle()
        :stroke("#2D6A4F3A")
        :fill("#2D6A4F3A")
        :strokewidth(sw)
        :linecap("square")
        :build()

    local bvbh = 2 * (randomamount + sw)
    local bsvgstr = h.svg():viewbox(0, -bvbh/2, w, bvbh):add(bottom_line):tostring()
    local bsvgdoc = frontend.parse_svg_string(bsvgstr)
    local bsvgnode = doc:create_svg_node(bsvgdoc, page.width)
    page:output_at(ml, bsvgnode.height / 2, bsvgnode)
end)
