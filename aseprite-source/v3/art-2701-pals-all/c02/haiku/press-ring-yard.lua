-- Press Ring (ow-press-ring), yard sprite 64x64. Haiku pass, c02 (worklist chunk 2).
-- Seedkeeper, uncommon. A thick stone hoop with two small knobs on top and a wooden press lever.
-- quirk: a drop of golden oil hangs from its lower lip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("press-ring-yard", 64)

local STONE = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

c:groundShadow(32, 58, 21, 3)

-- wooden press lever (behind the ring)
local lever, ln = O.tube({ { 48, 40 }, { 53, 36 }, { 58, 30 }, { 61, 25 } }, function(t) return 2 - .6 * t end)
O.shadeN(c, lever, ln, WOOD, { amb = .2, wrap = .35, sep = WOOD[1] })

-- two small knobs on top
O.shade(c, c:ellipse(25, 18, 3, 3), STONE, { R = 1, sep = STONE[1] })
O.shade(c, c:ellipse(39, 18, 3, 3), STONE, { R = 1, sep = STONE[1] })

-- the stone hoop
local outer = c:ellipse(32, 36, 21, 18)
local hole = c:ellipse(32, 33, 10, 8)
local ring = outer:copy():cut(hole)
O.shade(c, ring, STONE, { sphere = { 30, 30, 21 }, sep = STONE[1] })

-- face on the lower band: locked eyes, cheeks, nose, smile
c:eyeLocked(24, 44)
c:eyeLocked(35, 44)
c:cheek(17, 47)
c:cheek(42, 47)
O.dots(c, { { 31, 47 }, { 32, 47 } }, STONE[1])
O.dots(c, { { 29, 50 }, { 30, 51 }, { 31, 51 }, { 32, 51 }, { 33, 51 }, { 34, 50 } }, P.ink)

-- quirk: golden oil drip from the lower lip
O.dots(c, { { 32, 54 }, { 32, 55 } }, GOLD[2])
O.shade(c, c:ellipse(32, 57, 1, 2), GOLD, { R = 1, sep = GOLD[1] })

O.done(c, "press-ring-yard")
