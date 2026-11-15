-- Lofty Kite (sp-lofty-kite), yard sprite 64x64. Haiku pass, c06.
-- Rare, wayfinder. A diamond kite with a gold frame, a cross-spar and three ribbon tails.
-- Rare gets the fancier finish: gold trim, a cream sparkle and a multi-colour tail.
-- quirk: the pal looks down from the top of the kite; its eyes sit on the lower half of the diamond.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/h06.lua")
local HP, P = H.HP, H.P
local c = H.canvas("sp-lofty-kite-yard", 64)

-- ribbon tails (drawn first, the kite covers their tops)
c:part(c:line({ { 32, 40 }, { 27, 47 }, { 33, 53 }, { 28, 60 } }, 1.6), "ember", { band = 1 })
c:part(c:line({ { 32, 40 }, { 37, 48 }, { 31, 54 }, { 37, 59 } }, 1.6), "gold", { band = 1 })
c:part(c:line({ { 32, 40 }, { 25, 44 }, { 20, 52 }, { 24, 58 } }, 1.4), "petal", { band = 1 })

-- diamond body
local kite = c:poly{ { 32, 4 }, { 52, 22 }, { 32, 42 }, { 12, 22 } }
c:part(kite, "sea", { pop = { x = 20, y = 16, horizontal = true } })

-- gold trim: the outer ring of the diamond
local rim = kite:edge()
H.flat(c, rim, P.gold.base)

-- gold cross-spar
c:part(c:line({ { 32, 6 }, { 32, 40 } }, 1), "gold", { noshade = true })
c:part(c:line({ { 14, 22 }, { 50, 22 } }, 1), "gold", { noshade = true })

-- face (low on the diamond, looking down)
c:eyeLocked(23, 26)
c:eyeLocked(36, 26)
H.dots(c, { { 30, 33 }, { 31, 34 }, { 32, 34 }, { 33, 33 } }, P.ink)

-- rare sparkle
c:sparkle(49, 12)

H.done(c, "sp-lofty-kite-yard")
