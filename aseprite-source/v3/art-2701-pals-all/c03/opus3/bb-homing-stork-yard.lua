-- Homing Stork (bb-homing-stork), yard sprite 64x64. Opus second pass (art-2701-pals-all/c03/opus3), built on the
-- Haiku first pass. Rare, wayfinder, Birchbramble. "Knows the way home from anywhere and never asks directions."
-- A proper white stork, mid-stride: plump cream body, black flight feathers along the folded wing, S-curved neck,
-- big head with locked eye, long red bill, sturdy red legs (2 px, jointed knees, toes), a gold wayfinder scarf
-- whose end streams back. The first pass's teal wing and thin legs are gone.
-- quirk: it carries home with it, a tiny cottage (red roof, lit window) hanging on a string from its bill.
-- Rare: two sparkles.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("bb-homing-stork-yard", 64)

local STK  = { "#6e6680", "#9890a8", "#c2bccc", "#e2dde6", "#f4f0ee" }
local BLK  = { "#22182a", "#382a40", "#52425a", "#6e5e76" }
local BILL = { "#7a2018", "#b8361e", "#e05a2a", "#f48a4a" }
local GOLD = { "#7a4a14", "#b07a1e", "#e0a830", "#f4d060", "#fbec9e" }
local ROOF = { "#6a1e24", "#a8323a", "#d4544a" }
local WALL = { "#9a8070", "#cdb8a0", "#ecdcc4" }

c:groundShadow(29, 59, 15, 2.5)

-- legs (behind the body), jointed, with toes
local function leg(pts, toe)
  local m = c:line(pts, 2)
  m:add(c:line(toe, 1))
  O.shade(c, m, BILL, { R = 1, amb = .35, cuts = { .3, .55, .8 } })
end
leg({ { 25, 40 }, { 24, 48 }, { 22, 57 } }, { { 19, 58 }, { 25, 58 } })
leg({ { 32, 40 }, { 34, 48 }, { 35, 57 } }, { { 33, 58 }, { 39, 58 } })

-- tail
O.shade(c, c:poly{ { 16, 30 }, { 8, 31 }, { 10, 35 }, { 18, 36 } }, BLK, { R = 1, amb = .3, cuts = { .3, .55, .8 } })
-- body
local body = c:ellipse(28, 34, 13, 8)
O.shade(c, body, STK, { sphere = { 25, 30, 15 }, amb = .25, wrap = .4, cuts = { .25, .5, .72, .9 }, sep = STK[1], rim = true, bounce = "#8aa0c0", bmax = 2 })
-- folded wing: cream coverts then black flight feathers to the tail
local wing = c:poly{ { 18, 30 }, { 33, 30 }, { 38, 34 }, { 30, 38 }, { 14, 36 } }
local wI, wT = O.shade(c, wing, STK, { R = 2, amb = .3, cuts = { .25, .5, .72, .9 }, sep = STK[2] })
local prim = c:poly{ { 11, 33 }, { 26, 33 }, { 32, 36 }, { 28, 38 }, { 14, 38 } }
local pI, pT = O.shade(c, prim, BLK, { R = 1, amb = .35, cuts = { .3, .55, .8 } })
O.mark(c, { { 15, 34 }, { 16, 35 }, { 19, 34 }, { 20, 35 }, { 23, 34 }, { 24, 35 }, { 27, 35 }, { 28, 36 } }, BLK[1]) -- feather splits
O.mark(c, { { 21, 31 }, { 22, 32 }, { 26, 31 }, { 27, 32 }, { 31, 32 }, { 32, 33 } }, STK[2]) -- covert scallops

-- neck and head
local nk, nn = O.tube({ { 36, 31 }, { 41, 26 }, { 37, 19 }, { 40, 14 } }, function(t) return 3 - t * .8 end)
O.shadeN(c, nk, nn, STK, { amb = .35, wrap = .4, cuts = { .25, .5, .72, .9 }, sep = STK[1], rim = true })
local hd = c:ellipse(41, 11, 5.5, 5)
O.shade(c, hd, STK, { sphere = { 39, 9, 7 }, amb = .3, cuts = { .25, .5, .72, .9 }, sep = STK[1], rim = true })
-- long red bill
local bl, bn = O.tube({ { 45, 12 }, { 49, 13 }, { 53, 14 }, { 58, 16 } }, function(t) return 1.7 - t * 1.1 end)
O.shadeN(c, bl, bn, BILL, { amb = .35, cuts = { .3, .55, .8 }, sep = BILL[1] })
O.dots(c, { { 47, 13 }, { 50, 14 } }, BILL[1]) -- bill line

-- gold wayfinder scarf, end streaming back
local scarf = c:poly{ { 33, 22 }, { 43, 21 }, { 44, 26 }, { 34, 28 } }
local tail = c:poly{ { 35, 23 }, { 29, 23 }, { 24, 20 }, { 25, 24 }, { 28, 27 }, { 34, 28 } }
scarf:add(tail)
local gI, gT = O.shade(c, scarf, GOLD, { R = 1, amb = .35, cuts = { .25, .5, .72, .9 }, sep = GOLD[1] })
O.mark(c, { { 37, 23 }, { 37, 24 }, { 37, 25 }, { 37, 26 }, { 28, 24 }, { 29, 25 } }, GOLD[2])

-- face
c:eyeLocked(39, 8)
c:cheek(42, 14)

-- quirk: a tiny cottage hanging from the bill on a string
O.flat(c, c:line({ { 56, 16 }, { 56, 21 } }, 1), "#7a6a5a", "string")
local walls = c:rect(52, 26, 60, 32)
O.shade(c, walls, WALL, { R = 1, amb = .35, cuts = { .35, .7 }, sep = WALL[1] })
local roof = c:poly{ { 50, 26 }, { 56, 21 }, { 62, 26 } }
O.shade(c, roof, ROOF, { R = 1, amb = .35, cuts = { .35, .7 }, sep = ROOF[1] })
O.flat(c, c:rect(58, 21, 59, 23), ROOF[1], "chimney")
O.flat(c, c:rect(54, 28, 55, 29), GOLD[4], "window") O.dot(c, 54, 28, GOLD[5])
O.flat(c, c:rect(57, 29, 58, 32), "#6a3a2a", "door")

O.done(c, "bb-homing-stork-yard", function(c)
  c:sparkle(10, 18) c:sparkle(50, 4)
end)
