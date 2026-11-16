-- Golden Ring (mh-golden-ring), perch 36x36, hand-built at size. Haiku first pass, c00.
-- quirk: a little wheat sheaf stands inside the hole.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mh-golden-ring-perch", 36)

c:groundShadow(18, 33, 13, 2)
local ring = c:ellipse(18, 18, 13, 13)
ring:cut(c:ellipse(18, 18, 6, 6))
c:part(ring, "gold", { band = 2 })
c:fillMask(c:line({ { 18, 24 }, { 18, 12 } }, 1), P.wood.base)
c:px(17, 13, P.wood.hi) c:px(19, 13, P.wood.hi)
c:px(17, 15, P.wood.hi) c:px(19, 15, P.wood.hi)
c:eyeSmall(13, 26)
c:eyeSmall(21, 26)
c:px(17, 29, P.gold.hi) c:px(18, 29, P.gold.hi)
c:px(15, 30, P.ink) c:px(16, 31, P.ink) c:px(17, 31, P.ink) c:px(18, 31, P.ink) c:px(19, 30, P.ink)

M.done(c, "mh-golden-ring-perch")
