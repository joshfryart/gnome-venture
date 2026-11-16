-- Peat Sip (mm-peat-sip), perch sprite 36x36. Haiku first pass, c01. Peat dome, chimney smoke, teacup.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("mm-peat-sip-perch", 36)
local P = H.P

c:groundShadow(16, 33, 11, 2)
c:part(c:rect(21, 7, 24, 13), "stone", { band = 1 })
c:part(c:ellipse(25, 4, 2, 2), "sky", { band = 1 })
c:part(c:ellipse(29, 2, 1, 1), "sky", { noshade = true })
local dome = c:ellipse(15, 22, 12, 10)
c:part(dome, "wood", { band = 2 })
c:part(dome:copy():clip(c:rect(0, 0, 35, 16)), "moss", { band = 1 })
c:eyeSmall(11, 21)
c:eyeSmall(18, 21)
c:px(13, 26, P.ink) c:px(14, 26, P.ink) c:px(15, 26, P.ink)
c:part(c:rrect(25, 23, 31, 29, 1), "sky", { band = 1 })
c:px(28, 21, P.sky.base) c:px(29, 20, P.sky.base)

H.done(c, "mm-peat-sip-perch")
