-- Lofty Kite (sp-lofty-kite), perch sprite 36x36. Haiku pass, c06.
-- Hand-built at 36 px: a diamond kite with a gold spar and two ribbon tails. Rare, wayfinder.
-- Rare keeps the gold frame and a sparkle at this size.
-- quirk: the eyes sit low on the diamond, looking down.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("sp-lofty-kite-perch", 36)

c:part(c:line({ { 18, 24 }, { 15, 29 }, { 18, 33 } }, 1.2), "ember", { band = 1 })
c:part(c:line({ { 18, 24 }, { 21, 28 }, { 18, 33 } }, 1.2), "gold", { band = 1 })

local kite = c:poly{ { 18, 2 }, { 28, 12 }, { 18, 24 }, { 8, 12 } }
c:part(kite, "sea", { pop = { x = 12, y = 9, horizontal = true } })
H.flat(c, kite:edge(), P.gold.base)
c:part(c:line({ { 18, 4 }, { 18, 22 } }, 1), "gold", { noshade = true })
c:part(c:line({ { 10, 12 }, { 26, 12 } }, 1), "gold", { noshade = true })

c:eyeSmall(14, 14)
c:eyeSmall(21, 14)
H.dots(c, { { 17, 18 }, { 18, 18 } }, P.ink)
H.dot(c, 27, 4, P.cream)
H.done(c, "sp-lofty-kite-perch")
