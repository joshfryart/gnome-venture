-- trail-flooded (32x32 trail map marker, Haiku first pass). A dip in the road under a blue pool, two fence posts still
-- standing out of the water, pale ripple lines across the surface.
-- quirk: a lily pad with a pink petal flower floats on the water.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-flooded")

c:groundShadow(16, 28, 13, 2)
c:part(c:rect(5, 9, 7, 24), "wood")
c:part(c:rect(24, 9, 26, 24), "wood")
c:part(c:rect(2, 10, 29, 13), "wood", { nopop = true })
local pool = c:ellipse(16, 20, 14, 7)
c:part(pool, "sea", { band = 1 })
for _, l in ipairs{ { { 8, 17 }, { 12, 17 } }, { { 17, 15 }, { 22, 15 } }, { { 10, 24 }, { 15, 24 } }, { { 20, 23 }, { 25, 23 } } } do
  T.fill(c, c:line(l, 1):clip(pool), "#bfe6f6")
end
c:part(c:ellipse(12, 21, 2, 1), "moss", { nopop = true })
c:put(12, 20, "#ffc4d8") c:put(13, 20, "#ffc4d8")
c:put(5, 6, "#864c33")
T.done(c)
