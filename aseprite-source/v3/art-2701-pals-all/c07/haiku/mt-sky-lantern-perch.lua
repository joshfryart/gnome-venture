-- Sky Lantern (mt-sky-lantern), perch 36x36, hand-built at size. Haiku first pass, c07.
-- quirk: a sky ribbon trailing below and a gold glow.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mt-sky-lantern-perch", 36)

c:part(c:line({ { 16, 28 }, { 14, 34 } }, 1), "sky")
c:part(c:ellipse(18, 18, 8, 10), "ember", { band = 2 })
c:part(c:ellipse(18, 18, 3, 4), "gold", { noshade = true })
c:part(c:rect(11, 6, 25, 8), "wood")
c:part(c:rect(11, 27, 25, 29), "wood")
c:part(c:poly{ { 17, 6 }, { 19, 6 }, { 18, 3 } }, "wood")
c:eyeSmall(14, 15)
c:eyeSmall(20, 15)
c:px(17, 21, P.ink) c:px(18, 21, P.ink)
c:px(29, 10, P.sky.base) c:px(30, 14, P.sky.base)

M.done(c, "mt-sky-lantern-perch")
