-- Kernel Knock (mh-kernel-knock), yard 64x64. Haiku first pass, c00. Seedkeeper, common, Maizehollow.
-- A fat gold kernel with a half-popped white puff on top and a pointed tip, mouth open mid-pop.
-- quirk: two little knock ticks beside its head (it knocks twice, then pops).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mh-kernel-knock-yard", 64)

c:groundShadow(32, 58, 14, 3)
-- popped puff on top
local puff = c:ellipse(24, 18, 6, 5):add(c:ellipse(33, 14, 7, 6)):add(c:ellipse(42, 19, 5, 5))
c:part(puff, "sky")
-- kernel body with a pointed tip
local kern = c:ellipse(32, 36, 17, 15):add(c:poly{ { 27, 46 }, { 37, 46 }, { 33, 56 }, { 31, 56 } })
c:part(kern, "gold")
-- knock ticks (quirk)
c:fillMask(c:line({ { 51, 26 }, { 55, 23 } }, 1), P.ink)
c:fillMask(c:line({ { 51, 31 }, { 56, 31 } }, 1), P.ink)
-- face
c:eyeLocked(24, 33)
c:eyeLocked(36, 33)
c:cheek(20, 40) c:cheek(41, 40)
c:px(31, 39, P.gold.hi) c:px(32, 39, P.gold.hi)
c:px(31, 40, P.gold.deep) c:px(32, 40, P.gold.deep)
c:fillMask(c:rect(31, 43, 33, 44), P.ink)
c:px(32, 44, P.petal.base)

M.done(c, "mh-kernel-knock-yard")
