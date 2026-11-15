-- trail-delve (32x32 trail map marker, Haiku first pass). A square stone-rimmed hatch set in a grassy mound, the
-- hole opening into violet dark with a wooden ladder going down and a warm glow at the bottom. A pickaxe leans on the left.
-- quirk: a gold coin has rolled up over the rim, out of the hole.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-delve")

c:groundShadow(16, 27, 13, 2)
c:part(c:ellipse(16, 23, 13, 5), "moss")
local rim = c:rect(8, 12, 23, 22)
local hole = c:rect(10, 14, 21, 20)
c:part(rim, "stone", { nopop = true })
rim:cut(hole)
T.fill(c, hole, "#35295f")
T.fill(c, c:rect(13, 18, 18, 20), "#5a459e")
T.fill(c, c:rect(14, 19, 17, 20), "#f5b82e")
T.fill(c, c:line({ { 12, 15 }, { 12, 20 } }, 1):clip(hole), "#864c33")
T.fill(c, c:line({ { 19, 15 }, { 19, 20 } }, 1):clip(hole), "#864c33")
for _, y in ipairs{ 16, 18 } do T.fill(c, c:line({ { 12, y }, { 19, y } }, 1), "#b97a4a") end
c:part(c:ellipse(26, 23, 1, 1), "gold", { nopop = true })
c:line({ { 4, 7 }, { 7, 20 } }, 1):each(function(x, y) c:put(x, y, "#864c33") end)
c:part(c:poly{ { 1, 6 }, { 4, 3 }, { 6, 5 }, { 4, 7 } }, "stone", { nopop = true })
T.done(c)
