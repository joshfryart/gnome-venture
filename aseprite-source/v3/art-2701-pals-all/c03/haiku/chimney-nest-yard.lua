-- Chimney Nest (bb-chimney-nest), yard sprite 64x64. Haiku pass, c03.
-- Seedkeeper, uncommon. A twig nest sits on a brick chimney with a cream stork rising out of it.
-- quirk: a red bow is tied on the nest rim.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("chimney-nest-yard", 64)

local BRICK = { "#2b1c26", "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a", "#d9a070", "#e8b982", "#f6d8b0" }
local STORK = { "#74758c", "#aaa9b8", "#c8c6d2", "#e2e0e6", "#f4eee6", "#fff4d6" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local RED   = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

-- chimney stack (brick, drawn first; the nest covers its top)
local chim = c:rrect(15, 50, 49, 60, 1)
O.shade(c, chim, { "#51302b", "#6e2038", "#864c33", "#b52e3f", "#b97a4a", "#e8b982" }, { R = 2, sep = "#51302b" })
O.mark(c, { { 22, 54 }, { 23, 54 }, { 40, 56 }, { 41, 56 } }, "#e8b982")

-- nest
local nest = c:ellipse(32, 45, 17, 7)
O.shade(c, nest, WOOD, { sphere = { 29, 41, 16 }, amb = .25, wrap = .35, sep = WOOD[1] })
-- twig strokes on the nest
O.mark(c, { { 20, 44 }, { 21, 44 }, { 22, 45 }, { 36, 46 }, { 37, 46 }, { 38, 45 }, { 44, 44 }, { 45, 43 } }, WOOD[5])
O.mark(c, { { 14, 46 }, { 15, 46 }, { 16, 45 }, { 26, 48 }, { 27, 48 }, { 28, 48 } }, WOOD[1])

-- eggs in the nest
O.shade(c, c:ellipse(25, 45, 3, 2), STORK, { R = 1, sep = STORK[1] })
O.shade(c, c:ellipse(37, 44, 3, 2), STORK, { R = 1, sep = STORK[1] })

-- stork neck, rising out of the nest
local nm, nn = O.tube({ { 30, 42 }, { 31, 34 }, { 32, 27 }, { 34, 22 } }, function(t) return 3.2 - 0.6 * t end)
O.shadeN(c, nm, nn, STORK, { amb = .2, wrap = .35, sep = STORK[1] })

-- head
local head = c:ellipse(34, 19, 6, 5)
O.shade(c, head, STORK, { sphere = { 32, 16, 6 }, amb = .2, wrap = .35, sep = STORK[1] })

-- long gold beak
local bm, bn = O.tube({ { 38, 19 }, { 44, 18 }, { 50, 19 }, { 55, 20 } }, function(t) return 1.5 - 0.6 * t end)
O.shadeN(c, bm, bn, GOLD, { amb = .3, sep = GOLD[1] })

-- wing tuck at the nest edge
O.shade(c, c:ellipse(24, 41, 4, 3), STORK, { R = 1, sep = STORK[1] })

-- quirk: red bow tied on the nest rim
O.shade(c, c:ellipse(46, 43, 2, 2), RED, { R = 1, sep = RED[1] })
O.dots(c, { { 47, 45 }, { 48, 46 } }, RED[2])

-- face: locked eye, cheek, small beak mouth
c:eyeLocked(31, 17)
c:cheek(33, 22)

O.done(c, "chimney-nest-yard")
