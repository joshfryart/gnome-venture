-- Claw Sail (cs-claw-sail), yard sprite 64x64. Haiku pass, c08.
-- Uncommon, rootwarden. A red crab with a huge grin, sailing on a mast with a sky-blue sail cut into a crab claw.
-- quirk: the sail is itself a pincer, its open claw catching the wind.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("cs-claw-sail-yard", 64)

c:groundShadow(32, 58, 18, 2.5)
-- legs
c:part(c:line({ { 22, 44 }, { 14, 52 }, { 12, 56 } }, 2), "ember")
c:part(c:line({ { 28, 48 }, { 25, 56 }, { 24, 59 } }, 2), "ember")
c:part(c:line({ { 40, 48 }, { 43, 56 }, { 44, 59 } }, 2), "ember")
c:part(c:line({ { 46, 44 }, { 54, 52 }, { 56, 56 } }, 2), "ember")
-- mast and claw sail
c:part(c:line({ { 30, 38 }, { 30, 8 } }, 2), "wood")
local sail = c:ellipse(40, 16, 9, 7)
sail:cut(c:poly{ { 42, 14 }, { 56, 8 }, { 56, 24 } })
c:part(sail, "sky")
-- arm claws
c:part(c:line({ { 18, 40 }, { 10, 34 } }, 3), "ember")
c:part(c:ellipse(8, 30, 4, 3), "ember")
c:part(c:ellipse(56, 30, 4, 3), "ember")
-- body
c:part(c:ellipse(32, 42, 17, 10), "ember")
-- eyes on stalks
c:part(c:line({ { 24, 36 }, { 23, 31 } }, 2), "ember")
c:part(c:line({ { 40, 36 }, { 41, 31 } }, 2), "ember")
c:eyeLocked(21, 26)
c:eyeLocked(38, 26)
-- very large grin
c:fillMask(c:line({ { 19, 42 }, { 24, 47 }, { 32, 49 }, { 40, 47 }, { 45, 42 } }, 2), P.ink)

H.done(c, "cs-claw-sail-yard")
