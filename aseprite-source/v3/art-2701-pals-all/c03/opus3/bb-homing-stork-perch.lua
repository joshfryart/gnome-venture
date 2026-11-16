-- Homing Stork (bb-homing-stork), perch sprite 36x36. Opus richness pass (c03/opus3), hand-built at this size.
-- Richness pass: split lines and a sheen on the black primaries, a pale covert edge, a ribbed scarf, a lit cottage
-- window and door knob; the head stays big and clean so the pill eye reads.
-- Plump cream body with a black flight-feather band, S neck, a big head so the pill eye reads, red bill,
-- 2 px red legs, gold scarf. quirk: the tiny cottage hanging from the bill. Rare: one sparkle.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("bb-homing-stork-perch", 36)

local STK  = { "#6e6680", "#9890a8", "#c2bccc", "#e2dde6", "#f4f0ee" }
local BLK  = { "#22182a", "#382a40", "#52425a", "#6e5e76" }
local BILL = { "#7a2018", "#b8361e", "#e05a2a", "#f48a4a" }
local GOLD = { "#7a4a14", "#b07a1e", "#e0a830", "#f4d060", "#fbec9e" }
local ROOF = { "#6a1e24", "#a8323a", "#d4544a" }
local WALL = { "#9a8070", "#cdb8a0", "#ecdcc4" }

c:groundShadow(16, 33, 9, 1.5)
O.shade(c, c:line({ { 13, 24 }, { 12, 32 } }, 1):add(c:line({ { 9, 33 }, { 13, 33 } }, 1)), BILL, { R = 1, amb = .35, cuts = { .3, .55, .8 } })
O.shade(c, c:line({ { 18, 24 }, { 19, 32 } }, 1):add(c:line({ { 18, 33 }, { 22, 33 } }, 1)), BILL, { R = 1, amb = .35, cuts = { .3, .55, .8 } })
O.shade(c, c:poly{ { 8, 19 }, { 3, 20 }, { 4, 22 }, { 9, 23 } }, BLK, { R = 1, amb = .3, cuts = { .3, .55, .8 } })
O.shade(c, c:ellipse(15, 20.5, 8, 5), STK, { sphere = { 13, 18, 9 }, amb = .25, wrap = .4, cuts = { .25, .5, .72, .9 }, sep = STK[1], rim = true })
O.shade(c, c:poly{ { 5, 21 }, { 15, 21 }, { 19, 23 }, { 16, 24 }, { 7, 24 } }, BLK, { R = 1, amb = .35, cuts = { .3, .55, .8 }, sep = BLK[1] })
local nk, nn = O.tube({ { 20, 18 }, { 24, 14 }, { 21, 10 }, { 23, 7 } }, function(t) return 2 - t * .4 end)
O.shadeN(c, nk, nn, STK, { amb = .35, cuts = { .25, .5, .72, .9 }, sep = STK[1] })
O.shade(c, c:ellipse(24, 6, 3.5, 3.2), STK, { R = 2, amb = .3, cuts = { .25, .5, .72, .9 }, sep = STK[1], rim = true })
local bl, bn = O.tube({ { 27, 6.5 }, { 29, 7 }, { 31, 8 }, { 33, 9 } }, function(t) return 1.1 - t * .6 end)
O.shadeN(c, bl, bn, BILL, { amb = .35, cuts = { .3, .55, .8 } })
O.shade(c, c:poly{ { 19, 15 }, { 25, 14 }, { 25, 17 }, { 19, 18 } }:add(c:line({ { 19, 16 }, { 15, 15 } }, 1)), GOLD, { R = 1, amb = .35, cuts = { .25, .5, .72, .9 }, sep = GOLD[1] })
O.mark(c, { { 8, 22 }, { 11, 22 }, { 14, 23 } }, BLK[1]) O.mark(c, { { 7, 21 }, { 10, 21 }, { 13, 22 } }, BLK[4]) -- primaries
O.mark(c, { { 9, 20 }, { 12, 20 }, { 15, 20 } }, STK[2]) -- covert edge
O.mark(c, { { 20, 16 }, { 22, 16 }, { 24, 15 } }, GOLD[2]) -- scarf rib
c:eyeSmall(23, 4)
O.dot(c, 26, 8, "#f5809f")

-- quirk: the tiny cottage on a string
O.flat(c, c:line({ { 32, 10 }, { 32, 11 } }, 1), "#7a6a5a", "string")
O.shade(c, c:rect(29, 15, 34, 18), WALL, { R = 1, amb = .35, cuts = { .35, .7 }, sep = WALL[1] })
O.shade(c, c:poly{ { 28, 15 }, { 31.5, 12 }, { 35, 15 } }, ROOF, { R = 1, amb = .35, cuts = { .35, .7 }, sep = ROOF[1] })
O.dot(c, 30, 16, GOLD[4]) O.dot(c, 31, 16, GOLD[3]) O.dot(c, 33, 17, "#6a3a2a") O.dot(c, 33, 18, "#6a3a2a")

O.shift(c, -1, -1)
O.done(c, "bb-homing-stork-perch", function(c) c:sparkle(5, 8) end)
