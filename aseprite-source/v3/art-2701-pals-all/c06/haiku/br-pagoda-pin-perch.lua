-- Pagoda Pin (br-pagoda-pin), perch sprite 36x36. Haiku pass, c06.
-- Hand-built at 36 px: three ember roofs over wood walls, a gold spire, one arm up. Uncommon, rootwarden.
-- quirk: the arm points straight up at the spire top.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("br-pagoda-pin-perch", 36)

c:part(c:rect(4, 26, 32, 30), "stone", { band = 1 })
c:part(c:poly{ { 6, 17 }, { 30, 17 }, { 33, 20 }, { 3, 20 } }, "ember", { band = 1 })
c:part(c:rect(10, 20, 26, 25), "wood", { band = 1 })
c:part(c:poly{ { 9, 9 }, { 27, 9 }, { 31, 12 }, { 5, 12 } }, "ember", { band = 1 })
c:part(c:rect(12, 12, 24, 15), "wood", { band = 1 })
c:part(c:rect(17, 2, 18, 5), "gold", { noshade = true })
c:part(c:poly{ { 14, 6 }, { 22, 6 }, { 20, 9 }, { 16, 9 } }, "ember", { band = 1 })

c:part(c:line({ { 25, 24 }, { 30, 19 }, { 31, 13 } }, 1.6), "skinA", { band = 1 })
H.dot(c, 31, 11, P.skinA.base)

c:eyeSmall(13, 21)
c:eyeSmall(21, 21)
H.dots(c, { { 16, 24 }, { 17, 24 } }, P.ink)
H.done(c, "br-pagoda-pin-perch")
