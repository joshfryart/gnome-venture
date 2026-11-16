-- Golden Ring (mh-golden-ring), yard 64x64. Haiku first pass, c00. Rootwarden, uncommon, Maizehollow.
-- A thick gold hoop with a round hole; the hoop's lower band is the face.
-- quirk: a little wheat sheaf stands inside the hole ("a hole shaped like a good harvest").
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mh-golden-ring-yard", 64)

c:groundShadow(32, 58, 22, 3)
local ring = c:ellipse(32, 34, 22, 22)
ring:cut(c:ellipse(32, 34, 10, 10))
c:part(ring, "gold", { band = 3 })
-- wheat sheaf inside the hole (quirk)
c:fillMask(c:line({ { 32, 43 }, { 32, 25 } }, 1), P.wood.base)
for _, y in ipairs({ 24, 26, 28, 30 }) do
  c:px(31, y, P.wood.hi) c:px(33, y, P.wood.hi)
end
c:px(32, 23, P.wood.hi)
-- a glint on the hoop's upper left
c:sparkle(14, 28)
-- face on the lower band
c:eyeLocked(24, 47)
c:eyeLocked(36, 47)
c:cheek(19, 50) c:cheek(42, 50)
c:px(31, 51, P.gold.hi) c:px(32, 51, P.gold.hi)
c:px(31, 52, P.gold.deep) c:px(32, 52, P.gold.deep)
for _, p in ipairs({ { 29, 54 }, { 30, 55 }, { 31, 55 }, { 32, 55 }, { 33, 55 }, { 34, 54 } }) do c:px(p[1], p[2], P.ink) end

M.done(c, "mh-golden-ring-yard")
