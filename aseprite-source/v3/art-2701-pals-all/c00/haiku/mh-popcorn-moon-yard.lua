-- Popcorn Moon (mh-popcorn-moon), yard 64x64. Haiku first pass, c00. Brewroot, RARE, Maizehollow.
-- Rare, so a touch fancier: a gold crescent moon with craters, a cream sparkle and popcorn puffs on its rim.
-- quirk: popcorn puffs bursting off the rim (it goes pop at midnight).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mh-popcorn-moon-yard", 64)

-- popcorn puffs bursting off the top-left rim (quirk), drawn first so the moon overlaps them
c:part(c:ellipse(12, 12, 4, 4):add(c:ellipse(18, 6, 3, 3)):add(c:ellipse(6, 20, 3, 3)):add(c:ellipse(9, 28, 2, 2)), "sky")
-- crescent: big disc minus an offset disc
local moon = c:ellipse(32, 34, 22, 22)
moon:cut(c:ellipse(42, 24, 16, 16))
c:part(moon, "gold", { band = 3 })
-- craters
for _, p in ipairs({ { 14, 40 }, { 15, 40 }, { 20, 43 }, { 19, 44 }, { 13, 27 } }) do c:px(p[1], p[2], P.gold.shade) end
-- face
c:eyeLocked(16, 31)
c:eyeLocked(24, 31)
c:cheek(13, 37) c:cheek(27, 37)
c:px(21, 36, P.gold.hi) c:px(22, 36, P.gold.hi)
c:px(21, 37, P.gold.deep) c:px(22, 37, P.gold.deep)
for _, p in ipairs({ { 18, 39 }, { 19, 40 }, { 20, 40 }, { 21, 40 } }) do c:px(p[1], p[2], P.ink) end
-- sparkles for the midnight pop
c:sparkle(54, 10)
c:sparkle(56, 50)

M.done(c, "mh-popcorn-moon-yard")
