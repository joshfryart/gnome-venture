-- Torii Loop (br-torii-loop), perch 36x36, hand-built at size. Haiku first pass, c07.
-- quirk: a red torii gate on its head.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("br-torii-loop-perch", 36)

c:groundShadow(18, 33, 8, 2)
c:part(c:rect(12, 28, 14, 31), "wood")
c:part(c:rect(21, 28, 23, 31), "wood")
c:part(c:ellipse(18, 21, 9, 8), "gold", { band = 2 })
c:part(c:rect(9, 8, 27, 9), "ember")
c:part(c:rect(12, 12, 24, 13), "ember")
c:part(c:rect(11, 10, 12, 16), "ember")
c:part(c:rect(24, 10, 25, 16), "ember")
c:eyeSmall(14, 20)
c:eyeSmall(20, 20)
c:px(17, 25, P.ink) c:px(18, 25, P.ink)

M.done(c, "br-torii-loop-perch")
