-- Teal Ferry (sp-teal-ferry), perch sprite 36x36. Haiku pass, c06.
-- Hand-built at 36 px: a teal pal in a flat boat, one arm up in a wave. Uncommon, thornblade.
-- quirk: a gold fish in the water beside the boat.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("sp-teal-ferry-perch", 36)

c:part(c:rect(0, 28, 35, 35), "sea", { noshade = true })
c:part(c:ellipse(30, 31, 2, 1), "gold", { band = 1 })
H.dot(c, 31, 31, P.ink)

c:part(c:poly{ { 3, 24 }, { 33, 24 }, { 29, 30 }, { 7, 30 } }, "wood", { band = 1 })
c:part(c:ellipse(16, 19, 8, 7), "sea", { pop = { x = 11, y = 14, horizontal = true } })
c:part(c:line({ { 22, 20 }, { 27, 15 }, { 28, 10 } }, 2), "sea", { band = 1 })
H.dots(c, { { 28, 8 }, { 29, 8 }, { 28, 9 }, { 29, 9 } }, P.skinA.base)

c:eyeSmall(12, 17)
c:eyeSmall(19, 17)
H.dots(c, { { 14, 21 }, { 15, 22 }, { 16, 21 } }, P.ink)
H.done(c, "sp-teal-ferry-perch")
