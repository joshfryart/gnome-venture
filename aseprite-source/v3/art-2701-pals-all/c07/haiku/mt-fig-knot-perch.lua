-- Fig Knot (mt-fig-knot), perch 36x36, hand-built at size. Haiku first pass, c07.
-- quirk: a cream note wedged in the knot.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mt-fig-knot-perch", 36)

c:part(c:poly{ { 14, 10 }, { 8, 6 }, { 9, 12 } }, "moss")
c:part(c:poly{ { 22, 10 }, { 28, 6 }, { 27, 12 } }, "moss")
c:fillMask(c:rect(26, 9, 28, 11), P.cream)
c:part(c:ellipse(18, 20, 9, 9), "wood", { band = 2 })
c:fillMask(c:line({ { 10, 16 }, { 18, 14 }, { 26, 16 } }, 1), P.wood.deep)
c:fillMask(c:line({ { 10, 24 }, { 18, 26 }, { 26, 24 } }, 1), P.wood.deep)
c:part(c:ellipse(25, 26, 2, 2), "dusk", { noshade = true })
c:eyeSmall(14, 18)
c:eyeSmall(20, 18)
c:px(17, 23, P.ink) c:px(18, 23, P.ink)

M.done(c, "mt-fig-knot-perch")
