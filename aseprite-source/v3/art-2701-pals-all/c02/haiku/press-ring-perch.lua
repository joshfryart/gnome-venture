-- Press Ring (ow-press-ring), perch sprite 36x36. Haiku pass, c02 (worklist chunk 2), hand-built at this size.
-- quirk: a drop of golden oil hangs from its lower lip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("press-ring-perch", 36)

local STONE = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

c:groundShadow(18, 32, 12, 2)

-- press lever (behind the ring)
local lever, ln = O.tube({ { 27, 23 }, { 30, 20 }, { 33, 17 }, { 34, 15 } }, function(t) return 1.2 - .4 * t end)
O.shadeN(c, lever, ln, WOOD, { amb = .2, wrap = .35, sep = WOOD[1] })

-- two knobs on top
O.shade(c, c:ellipse(12, 9, 2, 2), STONE, { R = 1, sep = STONE[1] })
O.shade(c, c:ellipse(22, 9, 2, 2), STONE, { R = 1, sep = STONE[1] })

-- the stone hoop
local ring = c:ellipse(18, 20, 12, 10)
ring:cut(c:ellipse(18, 18, 5, 4))
O.shade(c, ring, STONE, { sphere = { 16, 16, 10 }, sep = STONE[1] })

-- face on the lower band
c:eyeSmall(12, 25)
c:eyeSmall(22, 25)
c:cheek(10, 27)
c:cheek(24, 27)
O.dots(c, { { 17, 24 }, { 18, 24 } }, STONE[1])
O.dots(c, { { 15, 28 }, { 16, 29 }, { 17, 29 }, { 18, 29 }, { 19, 29 }, { 20, 28 } }, P.ink)

-- quirk: golden oil drip
O.dot(c, 18, 31, GOLD[2])

O.done(c, "press-ring-perch")
