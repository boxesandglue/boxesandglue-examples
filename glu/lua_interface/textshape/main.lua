local ts = require("glu.textshape")

-- Load font and create shaper
local font = ts.parse_font("../../fonts/crimsonpro/CrimsonPro-Regular.ttf")
local shaper = ts.new_shaper(font)

-- Create buffer and add text
local text = "office"
local buf = ts.new_buffer()
buf:add_string(text)
buf:guess_segment_properties()

-- Shape with features
shaper:shape(buf, {"+liga", "+kern"})

-- Read results and reconstruct original sequences via cluster values.
-- After shaping, info.codepoint only contains the first codepoint of the
-- original sequence (e.g. for an "ffi" ligature, codepoint is just "f").
-- To recover the full original sequence, use the cluster field to index
-- back into the original string.
for i = 1, #buf do
    local info = buf.info[i]
    local pos = buf.pos[i]

    -- cluster is a 0-based codepoint index into the original string.
    -- The range for this glyph spans from its cluster value to the next
    -- glyph's cluster value (or end of string for the last glyph).
    local cluster_start = info.cluster
    local cluster_end
    if i < #buf then
        cluster_end = buf.info[i + 1].cluster
    else
        cluster_end = #text
    end
    local original = string.sub(text, cluster_start + 1, cluster_end)

    print(string.format("glyph=%d cluster=%d advance=%d codepoint=U+%04X original=%q",
        info.glyph_id, info.cluster, pos.x_advance, info.codepoint, original))
end
