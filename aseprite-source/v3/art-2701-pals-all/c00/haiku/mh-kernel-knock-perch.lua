-- Kernel Knock (mh-kernel-knock), perch 36x36, hand-built at size. Haiku first pass, c00.
-- quirk: two knock ticks beside its head.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mh-kernel-knock-perch", 36)

c:groundShadow(18, 33, 8, 2)
c:part(c:ellipse(12, 9, 3, 3):add(c:ellipse(18, 7, 4, 4)):add(c:ellipse(24, 10, 3, 3)), "sky")
c:part(c:ellipse(18, 20, 10, 9):add(c:poly{ { 15, 27 }, { 21, 27 }, { 18, 31 } }), "gold")
c:fillMask(c:line({ { 29, 12 }, { 31, 10 } }, 1), P.ink)
c:fillMask(c:line({ { 29, 17 }, { 32, 17 } }, 1), P.ink)
c:eyeSmall(14, 19)
c:eyeSmall(20, 19)
c:px(17, 22, P.gold.hi) c:px(18, 22, P.gold.hi)
c:px(17, 23, P.gold.deep) c:px(18, 23, P.gold.deep)
c:px(17, 25, P.ink) c:px(18, 25, P.ink) c:px(17, 26, P.petal.base)

M.done(c, "mh-kernel-knock-perch")
