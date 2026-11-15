-- Petal Pinch (br-petal-pinch), perch sprite 36x36. Haiku pass, c06.
-- Hand-built at 36 px: a round pink pal, a wood pocket with petals, one petal held up. Common, bloomcaller.
-- quirk: a falling petal at the top left.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("br-petal-pinch-perch", 36)

c:part(c:ellipse(18, 19, 10, 10), "petal", { pop = { x = 12, y = 13, horizontal = true } })
c:part(c:poly{ { 27, 12 }, { 31, 7 }, { 33, 10 }, { 29, 13 } }, "petal", { band = 1 })
c:part(c:poly{ { 4, 6 }, { 7, 4 }, { 8, 8 }, { 5, 9 } }, "petal", { band = 1 })

c:part(c:rrect(11, 24, 25, 30, 2), "wood", { band = 1 })
c:part(c:poly{ { 13, 24 }, { 15, 21 }, { 17, 24 } }, "petal", { band = 1 })
c:part(c:poly{ { 19, 24 }, { 21, 20 }, { 23, 24 } }, "petal", { band = 1 })

c:eyeSmall(13, 15)
c:eyeSmall(21, 15)
H.dots(c, { { 17, 19 }, { 18, 20 }, { 19, 19 } }, P.ink)
H.done(c, "br-petal-pinch-perch")
