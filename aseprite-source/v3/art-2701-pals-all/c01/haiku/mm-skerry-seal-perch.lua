-- Skerry Seal (mm-skerry-seal), perch sprite 36x36. Haiku first pass, c01. Grey seal on a rock, lighthouse behind.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("mm-skerry-seal-perch", 36)
local P = H.P

c:part(c:poly { { 26, 12 }, { 28, 4 }, { 31, 4 }, { 33, 12 } }, "sky", { band = 1 })
c:part(c:rect(27, 8, 32, 9), "ember", { noshade = true })
c:part(c:rect(27, 3, 32, 4), "gold", { noshade = true })
c:part(c:ellipse(18, 30, 15, 4), "stone", { band = 2 })
c:part(c:ellipse(18, 24, 11, 6), "stone", { band = 2 })
c:part(c:ellipse(9, 19, 5, 5), "stone", { band = 2 })
c:px(5, 21, P.sky.base) c:px(6, 21, P.sky.base) c:px(7, 21, P.sky.base)
c:eyeSmall(7, 17)
c:eyeSmall(11, 17)
c:px(5, 22, P.ink) c:px(6, 22, P.ink) c:px(7, 22, P.ink)
c:px(2, 19, P.ink) c:px(1, 21, P.ink)

H.done(c, "mm-skerry-seal-perch")
