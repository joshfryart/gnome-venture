-- Bill Brolly (mt-bill-brolly), yard 64x64. Haiku first pass, c07. Wayfinder, rare, Monsoontangle.
-- A dusk-plum hornbill with a gold beak and ember casque, under a giant moss leaf, sharing it with a frog.
-- rare: a sparkle on the wing. quirk: the leaf umbrella held over the bird, with a moss frog tucked at its edge.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local M = dofile(dir .. "/_haiku.lua")
local HP, P = M.HP, M.P
local c = M.canvas("mt-bill-brolly-yard", 64)

-- leaf umbrella and stem
c:part(c:line({ { 32, 18 }, { 32, 24 } }, 1), "wood")
local leaf = c:ellipse(32, 10, 27, 7)
c:part(leaf, "moss", { band = 3 })
c:fillMask(c:line({ { 8, 12 }, { 56, 9 } }, 1), P.moss.deep)
c:fillMask(c:line({ { 32, 4 }, { 32, 16 } }, 1), P.moss.deep)
-- wing
c:part(c:poly{ { 22, 34 }, { 12, 44 }, { 14, 54 }, { 22, 50 }, { 24, 40 } }, "dusk", { band = 2 })
-- body and belly
c:part(c:ellipse(32, 40, 13, 13), "dusk", { band = 3 })
c:part(c:ellipse(31, 45, 6, 8), "stone", { band = 1 })
-- head
c:part(c:ellipse(30, 28, 9, 8), "dusk", { band = 2 })
-- gold beak with ember casque
c:part(c:poly{ { 36, 25 }, { 54, 30 }, { 36, 35 } }, "gold", { band = 2 })
c:part(c:poly{ { 40, 22 }, { 46, 25 }, { 40, 26 } }, "ember")
-- face
c:eyeLocked(24, 25)
c:eyeLocked(31, 25)
-- legs
c:part(c:line({ { 28, 52 }, { 27, 58 } }, 1), "gold")
c:part(c:line({ { 35, 52 }, { 36, 58 } }, 1), "gold")
-- moss frog tucked under the leaf edge
c:part(c:ellipse(9, 50, 5, 3), "moss", { band = 1 })
c:part(c:ellipse(7, 47, 2, 2), "moss", { noshade = true })
c:sparkle(52, 40)

M.done(c, "mt-bill-brolly-yard")
