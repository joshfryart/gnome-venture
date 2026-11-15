-- trail-overgrown (32x32 trail map marker, Haiku first pass). An old signpost with a faded paper board, its foot swallowed
-- by a heap of bramble in three moss tones with thorn ticks. The road is gone under it.
-- quirk: a bird's nest with two pale blue eggs is tucked into the bramble on the post.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-overgrown")

c:groundShadow(16, 28, 12, 2)
c:part(c:rect(14, 4, 17, 27), "wood")
c:part(c:rect(7, 4, 24, 10), "sky")
for _, y in ipairs{ 6, 8 } do T.fill(c, c:line({ { 9, y }, { 22, y } }, 1), "#8bc4ea") end
local br = c:ellipse(8, 21, 7, 6):add(c:ellipse(23, 20, 7, 6)):add(c:ellipse(16, 24, 10, 4))
c:part(br, "moss")
for _, p in ipairs{ { 5, 18 }, { 12, 17 }, { 21, 16 }, { 27, 22 }, { 9, 26 }, { 19, 26 } } do c:put(p[1], p[2], "#24544a") end
c:line({ { 2, 24 }, { 10, 22 }, { 18, 25 }, { 29, 23 } }, 1):each(function(x, y) if br:has(x, y) then c:put(x, y, "#3f9150") end end)
c:part(c:ellipse(21, 15, 3, 1), "wood", { nopop = true })
T.fill(c, c:ellipse(21, 14, 2, 1):clip(c:ellipse(21, 15, 3, 1)), "#c9925a")
c:put(20, 14, "#8aa6dc") c:put(22, 14, "#8aa6dc")
T.done(c)
