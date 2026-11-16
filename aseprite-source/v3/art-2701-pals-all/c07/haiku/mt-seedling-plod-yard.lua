-- Seedling Plod (mt-seedling-plod), yard 64x64. Haiku first pass, c07. Wayfinder, common, Monsoontangle.
-- A squat moss blob with wood clog-feet, a seedling sprouting from its head, and singing.
-- quirk: a sea-blue music note floats beside it (it sings to each seedling).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mt-seedling-plod-yard", 64)

c:groundShadow(32, 60, 16, 3)
-- plodding clog feet
c:part(c:ellipse(24, 56, 5, 3), "wood")
c:part(c:ellipse(40, 56, 5, 3), "wood")
-- body
c:part(c:ellipse(32, 38, 15, 15), "moss", { band = 3 })
-- seedling on the head
c:part(c:line({ { 32, 25 }, { 32, 13 } }, 1), "moss")
c:part(c:poly{ { 31, 15 }, { 24, 9 }, { 22, 14 }, { 29, 18 } }, "gold")
c:part(c:poly{ { 33, 14 }, { 40, 8 }, { 42, 13 }, { 35, 17 } }, "gold")
-- face
c:eyeLocked(24, 33)
c:eyeLocked(35, 33)
c:cheek(21, 40) c:cheek(40, 40)
c:fillMask(c:rect(31, 41, 32, 42), P.ink)
-- sung note (quirk)
c:fillMask(c:line({ { 49, 16 }, { 49, 23 } }, 1), P.sea.base)
c:fillMask(c:rect(46, 22, 49, 25), P.sea.base)

M.done(c, "mt-seedling-plod-yard")
