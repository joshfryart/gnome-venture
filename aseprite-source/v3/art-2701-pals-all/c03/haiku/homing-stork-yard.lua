-- Homing Stork (bb-homing-stork), yard sprite 64x64. Haiku pass, c03.
-- Wayfinder, rare (fancier: gold trim, sparkles). Tall cream stork with long legs, a gold beak and a
-- tiny house bundle strapped to its back.
-- quirk: the bundle is a little house with one lit window.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("homing-stork-yard", 64)

local STORK = { "#74758c", "#aaa9b8", "#c8c6d2", "#e2e0e6", "#f4eee6", "#fff4d6" }
local WING  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#9ee4dc" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local EMBER = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c", "#ffc0a0" }

c:groundShadow(32, 60, 14, 2)

-- long legs
local l1 = O.tube({ { 28, 46 }, { 27, 50 }, { 27, 54 }, { 26, 58 } }, function(t) return .9 end)
local lm, ln = O.tube({ { 28, 46 }, { 27, 50 }, { 27, 54 }, { 26, 58 } }, function(t) return .9 end)
O.shadeN(c, lm, ln, GOLD, { amb = .3, sep = GOLD[1] })
local rm, rn = O.tube({ { 34, 46 }, { 35, 50 }, { 36, 54 }, { 37, 58 } }, function(t) return .9 end)
O.shadeN(c, rm, rn, GOLD, { amb = .3, sep = GOLD[1] })
O.dots(c, { { 25, 58 }, { 26, 58 }, { 36, 58 }, { 37, 58 } }, GOLD[1])

-- body
local body = c:ellipse(30, 38, 13, 10)
O.shade(c, body, STORK, { sphere = { 26, 34, 13 }, amb = .2, wrap = .35, sep = STORK[1], rim = true })

-- wing (teal flight feathers at the tip, cream coverts)
local wing = c:ellipse(24, 38, 8, 5)
O.shade(c, wing, WING, { R = 2, sep = WING[1] })
O.mark(c, { { 19, 41 }, { 18, 40 }, { 17, 40 } }, WING[4])

-- neck and head
local nm, nn = O.tube({ { 36, 34 }, { 39, 29 }, { 39, 23 }, { 40, 18 } }, function(t) return 3.2 - 0.7 * t end)
O.shadeN(c, nm, nn, STORK, { amb = .2, wrap = .35, sep = STORK[1] })
local head = c:ellipse(40, 16, 5, 4)
O.shade(c, head, STORK, { sphere = { 38, 14, 5 }, amb = .2, wrap = .35, sep = STORK[1] })

-- gold scarf at the neck
local scarf = c:rrect(36, 26, 42, 28, 1)
O.shade(c, scarf, GOLD, { R = 1, sep = GOLD[1] })

-- long gold beak
local bm, bn = O.tube({ { 44, 16 }, { 50, 15 }, { 56, 15 }, { 60, 16 } }, function(t) return 1.5 - 0.6 * t end)
O.shadeN(c, bm, bn, GOLD, { amb = .3, sep = GOLD[1] })

-- quirk: a tiny house bundle strapped to the back, with one lit window
local roof = c:poly({ { 12, 29 }, { 16, 24 }, { 20, 29 } })
O.shade(c, roof, EMBER, { R = 1, sep = EMBER[1] })
local house = c:rect(13, 29, 19, 36)
O.shade(c, house, EMBER, { R = 1, sep = EMBER[1] })
O.dot(c, 16, 32, GOLD[3])
O.dot(c, 16, 33, GOLD[4])
O.dot(c, 17, 32, GOLD[4])
-- strap
O.flat(c, c:rect(20, 31, 23, 33), GOLD[2], "strap")

-- rare fancier: sparkles
c:sparkle(50, 8)
c:sparkle(8, 40)

-- face
c:eyeLocked(37, 14)
c:cheek(35, 20)

O.done(c, "homing-stork-yard")
