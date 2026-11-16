-- Gander Gait (bb-gander-gait), perch sprite 36x36. Opus richness pass (c02/opus3), built on opus2, hand-built at this size.
-- Fix (opus3): the pill eye sat small in the head. The head is a touch smaller (8x7) so the eye fills more of it,
-- the eye sits in a cool grey eye-ring with a proud dark brow arc over it, and the cheek is right under it, so the
-- face reads as a face at 36 px. Richness: wing scallop row, neck furrow, lit beak ridge, fuzzy goslings.
-- Plump cream-white gander mid-step: thick neck, big head with a pill eye, orange beak, keyhole crest tuft.
-- Fix vs Haiku: perch head was small and the chicks were 2x2 dots; now the head holds the eye and cheek
-- clearly, and the two goslings each have a head, beak and eye.
-- quirk: goslings marching behind in a line.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("bb-gander-gait-perch", 36)

local WH  = { "#4e4e70", "#7c7c9c", "#a8a8c0", "#cfcdd8", "#e8e6e4", "#f6f3ea" }
local ORG = { "#7a2c1a", "#b8481e", "#e0702a", "#f4a040", "#fbcc6c" }
local CH  = { "#8a6a1c", "#c89a26", "#f0c83a", "#fce680" }

c:groundShadow(19, 31, 15, 1.2)
-- legs
O.flat(c, c:rect(20, 26, 20, 30), ORG[3], "leg") O.flat(c, c:rect(18, 31, 21, 31), ORG[3], "foot")
O.flat(c, c:rect(23, 26, 24, 27), ORG[3], "leg") O.flat(c, c:rect(25, 27, 26, 28), ORG[4], "foot")

local body = c:ellipse(18, 22, 8, 5.5)
body:add(c:poly{ { 11, 21 }, { 7, 16 }, { 9, 16 }, { 14, 19 } })
O.shade(c, body, WH, { sphere = { 15, 18, 10 }, amb = .25, wrap = .35, rim = true })
O.dots(c, { { 14, 22 }, { 16, 23 }, { 18, 23 } }, WH[2]) -- wing feather tips
O.dots(c, { { 13, 20 }, { 14, 20 }, { 15, 21 }, { 16, 21 }, { 17, 21 } }, WH[3]) -- wing edge
O.dots(c, { { 15, 19 }, { 17, 19 }, { 19, 20 } }, WH[3]) -- scallop row

local neck, nn = O.tube({ { 23, 21 }, { 27, 16 }, { 23, 12 }, { 25, 8 } }, function(t) return 2.2 - t * .4 end)
O.shadeN(c, neck, nn, WH, { amb = .3, wrap = .35, rim = true, sep = WH[3], bounce = "#9a8ab8", bmax = 2 })
O.shade(c, c:ellipse(26, 7.5, 3.5, 3), WH, { sphere = { 25, 5, 5 }, amb = .3, wrap = .35, rim = true, sep = WH[3] })
-- keyhole crest
O.flat(c, c:rect(25, 1, 26, 3), WH[5], "crest") O.dot(c, 25, 1, WH[6]) O.dot(c, 26, 2, WH[2])
-- beak
O.shade(c, c:poly{ { 29, 7 }, { 33, 8 }, { 33, 9 }, { 29, 10 } }, ORG, { R = 1, amb = .3, sep = ORG[1], cuts = { .25, .45, .65, .84 } })
-- eye-ring + proud brow, then the locked pill
O.dots(c, { { 25, 6 }, { 25, 7 }, { 25, 8 }, { 26, 9 }, { 27, 9 }, { 28, 7 }, { 28, 8 } }, WH[3])
O.dots(c, { { 25, 5 }, { 26, 4 }, { 27, 4 }, { 28, 5 } }, WH[1])
c:eyeSmall(26, 6)
O.dot(c, 25, 9, "#f5809f") O.dot(c, 24, 9, "#f5809f")

local function gosling(x, y)
  O.shade(c, c:ellipse(x, y, 2, 1.6), CH, { R = 1, amb = .3, sep = CH[1], cuts = { .3, .55, .8 } })
  O.shade(c, c:ellipse(x + 1.5, y - 2.5, 1.5, 1.5), CH, { R = 1, amb = .35, sep = CH[1], cuts = { .3, .55, .8 } })
  O.dot(c, x + 3, y - 3, ORG[3])
  O.dot(c, x + 2, y - 3, P.ink)
  O.dot(c, x + 1, y - 4, CH[4]) O.dot(c, x - 1, y - 1, CH[4])
  O.dot(c, x, y + 2, ORG[3])
end
gosling(11, 28)
gosling(5, 28)

O.shift(c, 0, 1)
O.done(c, "bb-gander-gait-perch")
