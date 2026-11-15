-- Palm Fidget (ss-palm-fidget), perch 36x36, hand-built at size. Haiku first pass, c00.
-- quirk: fronds curled into a fidget loop, breeze tick to the right.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("ss-palm-fidget-perch", 36)

c:groundShadow(18, 33, 8, 2)
c:part(c:line({ { 17, 16 }, { 10, 10 }, { 4, 12 } }, 2), "moss")
c:part(c:line({ { 19, 16 }, { 27, 9 }, { 33, 11 } }, 2), "moss")
c:part(c:line({ { 18, 14 }, { 20, 6 }, { 24, 4 }, { 26, 7 } }, 1), "moss")
c:part(c:ellipse(18, 22, 10, 9), "wood")
c:fillMask(c:line({ { 30, 22 }, { 34, 21 } }, 1), P.sky.base)
c:px(14, 27, P.wood.deep) c:px(22, 27, P.wood.deep)
c:eyeSmall(13, 21)
c:eyeSmall(21, 21)
c:px(17, 24, P.wood.hi) c:px(18, 24, P.wood.hi)
c:px(15, 26, P.ink) c:px(16, 27, P.ink) c:px(17, 27, P.ink) c:px(18, 27, P.ink) c:px(19, 26, P.ink)

M.done(c, "ss-palm-fidget-perch")
