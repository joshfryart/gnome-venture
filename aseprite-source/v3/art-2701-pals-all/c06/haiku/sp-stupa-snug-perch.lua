-- Stupa Snug (sp-stupa-snug), perch sprite 36x36. Haiku pass, c06.
-- Hand-built at 36 px: a sky-white dome over a dusk body, three prayer flags. Uncommon, rootwarden.
-- quirk: the prayer flags are pegged out on one straight string.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("sp-stupa-snug-perch", 36)

c:part(c:ellipse(18, 23, 10, 9), "dusk", { pop = { x = 12, y = 18, horizontal = true } })
c:part(c:rect(9, 14, 27, 16), "gold", { band = 1 })
local dome = c:ellipse(18, 12, 7, 6)
dome:cut(c:rect(0, 14, 35, 35))
c:part(dome, "sky", { pop = { x = 13, y = 9, horizontal = true } })
c:part(c:rect(17, 2, 18, 5), "gold", { noshade = true })
H.dot(c, 17, 1, P.gold.hi)

c:part(c:line({ { 3, 17 }, { 18, 20 }, { 33, 17 } }, 1), "wood", { noshade = true })
c:part(c:rect(5, 17, 7, 20), "sea", { noshade = true })
c:part(c:rect(16, 19, 18, 22), "ember", { noshade = true })
c:part(c:rect(27, 17, 29, 20), "moss", { noshade = true })

c:eyeSmall(13, 23)
c:eyeSmall(21, 23)
H.dots(c, { { 16, 27 }, { 17, 28 }, { 18, 28 }, { 19, 27 } }, P.ink)
H.done(c, "sp-stupa-snug-perch")
