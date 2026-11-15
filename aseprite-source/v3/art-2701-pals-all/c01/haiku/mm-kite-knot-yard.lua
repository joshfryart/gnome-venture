-- Kite Knot (mm-kite-knot), yard 64x64. Haiku first pass, c01. Thornblade, uncommon, Mistmoor.
-- An ember kite with a gold border, a dusk-violet spar cross and a long tail.
-- quirk: the tail ends in a petal bow, and steam puffs off the top right in a huff.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("mm-kite-knot-yard", 64)
local P = H.P

c:groundShadow(32, 61, 12, 2)

-- the tail with its bow (drawn first)
c:part(c:line({ { 32, 50 }, { 30, 60 } }, 1), "dusk", { noshade = true })
c:part(c:poly { { 30, 57 }, { 22, 52 }, { 22, 62 } }, "petal", { band = 1 })
c:part(c:poly { { 30, 57 }, { 38, 52 }, { 38, 62 } }, "petal", { band = 1 })
c:part(c:ellipse(30, 57, 2, 2), "gold", { band = 1 })

-- the kite diamond
local kite = c:poly { { 32, 4 }, { 54, 28 }, { 32, 52 }, { 10, 28 } }
c:part(kite, "ember", { band = 3 })
-- gold border
c:stitch({ { 32, 4 }, { 54, 28 }, { 32, 52 }, { 10, 28 }, { 32, 4 } })
-- dusk spar cross
c:part(c:line({ { 32, 6 }, { 32, 50 } }, 1), "dusk", { noshade = true })
c:part(c:line({ { 12, 28 }, { 52, 28 } }, 1), "dusk", { noshade = true })

-- angry face
c:eyeLocked(22, 30)
c:eyeLocked(37, 30)
-- angry brows slanting in
c:px(20, 26, P.ink) c:px(21, 27, P.ink) c:px(22, 28, P.ink)
c:px(42, 26, P.ink) c:px(41, 27, P.ink) c:px(40, 28, P.ink)
-- a flat, cross mouth
for x = 27, 36 do c:px(x, 40, P.ink) end
c:px(27, 39, P.ink) c:px(36, 39, P.ink)

-- huff puffs off the top right
c:part(c:ellipse(55, 10, 3, 2), "sky", { band = 1 })
c:part(c:ellipse(59, 5, 2, 2), "sky", { band = 1 })

H.done(c, "mm-kite-knot-yard")
