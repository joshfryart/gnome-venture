-- Gander Gait (bb-gander-gait), yard sprite 64x64. Opus second pass (art-2701-pals-all/c02/opus2), built on the Haiku pass.
-- Wayfinder, common, Birchbramble. "Marches in a neat line and expects everyone to follow."
-- A plump cream-white gander mid-march: chest out, a thick S-curved neck, head held high with a proud locked eye,
-- an orange beak, and a little keyhole-shaped crest feather on top (keyhole knob). Folded wing with scalloped
-- feather rows, one webbed foot planted and one lifted in a high step.
-- Fix vs Haiku: the neck was thin and the head small; now a 6-7 px neck and a head big enough for a full eye;
-- cool-violet shadows on the white so it never goes flat; the chicks are real goslings (head, beak, eye).
-- quirk: three fuzzy yellow goslings march behind it in a neat line, the last one out of step.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("bb-gander-gait-yard", 64)

local WH  = { "#4e4e70", "#7c7c9c", "#a8a8c0", "#cfcdd8", "#e8e6e4", "#f6f3ea" }
local ORG = { "#7a2c1a", "#b8481e", "#e0702a", "#f4a040", "#fbcc6c" }
local CH  = { "#8a6a1c", "#c89a26", "#f0c83a", "#fce680" }

c:groundShadow(34, 56, 26, 2.2)

-- legs (behind body): planted leg + raised marching leg
O.shade(c, c:rect(34, 46, 35, 54), ORG, { R = 1, amb = .3, sep = ORG[1], cuts = { .25, .45, .65, .84 } })
O.shade(c, c:poly{ { 31, 55 }, { 38, 55 }, { 39, 56 }, { 31, 56 } }, ORG, { R = 1, amb = .3, sep = ORG[1], cuts = { .25, .45, .65, .84 } })
O.shade(c, c:line({ { 40, 46 }, { 43, 50 }, { 46, 49 } }, 2), ORG, { R = 1, amb = .3, sep = ORG[1], cuts = { .25, .45, .65, .84 } })
O.shade(c, c:poly{ { 45, 47 }, { 49, 48 }, { 49, 51 }, { 46, 51 } }, ORG, { R = 1, amb = .3, sep = ORG[1], cuts = { .25, .45, .65, .84 } })

-- body: plump with an upturned tail point
local body = c:ellipse(32, 39, 14, 9)
body:add(c:poly{ { 20, 36 }, { 13, 29 }, { 15, 28 }, { 24, 33 } })
local bb = {}
body:each(function(x, y) if y > 45 then bb[K(x, y)] = -1 end end)
local bI, bT = O.shade(c, body, WH, { sphere = { 28, 32, 18 }, bias = bb, amb = .25, wrap = .35, rim = true, bounce = "#9a8ab8", bmax = 2 })

-- neck: thick S-curve up to the head
local neck, nn = O.tube({ { 41, 38 }, { 47, 30 }, { 40, 22 }, { 44, 14 } }, function(t) return 3.6 - t * .8 end)
O.shadeN(c, neck, nn, WH, { amb = .3, wrap = .35, rim = true, sep = WH[3] })
-- head
local head = c:ellipse(45, 13, 5.5, 4.5)
O.shade(c, head, WH, { sphere = { 43, 10, 7 }, amb = .3, wrap = .35, rim = true, sep = WH[3] })
-- keyhole crest: a round tuft on a narrow stem
O.shade(c, c:rect(44, 6, 45, 8), WH, { R = 1, amb = .35, sep = WH[2] })
O.shade(c, c:ellipse(44.5, 4, 2, 1.8), WH, { R = 1, amb = .35, sep = WH[2] })
O.dot(c, 44, 4, WH[2]) O.dot(c, 45, 4, WH[2]) -- the keyhole's dark eye
-- beak
local beak = c:poly{ { 49, 12 }, { 56, 13 }, { 56, 15 }, { 49, 16 } }
O.shade(c, beak, ORG, { R = 1, amb = .3, sep = ORG[1], cuts = { .25, .45, .65, .84 } })
O.dots(c, { { 50, 14 }, { 51, 14 }, { 52, 14 }, { 53, 14 }, { 54, 14 } }, ORG[2]) -- mouth line
O.dot(c, 55, 13, ORG[1]) -- nail
-- proud eye + cheek
c:eyeLocked(43, 10)
O.dots(c, { { 42, 16 }, { 43, 16 } }, "#f5809f")

-- folded wing with scalloped feather rows
local wing = c:ellipse(29, 38, 9, 5)
wing:add(c:poly{ { 21, 37 }, { 17, 33 }, { 25, 35 } })
local wb = {}
wing:each(function(x, y)
  if (y == 36 and x % 4 == 0) or (y == 37 and x % 4 ~= 0 and x % 2 == 0) or (y == 40 and x % 4 == 2) then wb[K(x, y)] = -2 end
end)
local wI, wT = O.shade(c, wing, WH, { R = 3, bias = wb, amb = .25, wrap = .35, sep = WH[2] })
O.dots(c, { { 21, 41 }, { 23, 42 }, { 25, 43 } }, WH[2]) -- primary tips

-- quirk: three goslings marching behind, the last one out of step
local function gosling(x, y, lift)
  O.shade(c, c:ellipse(x, y, 3, 2.5), CH, { R = 1.5, amb = .3, sep = CH[1], cuts = { .3, .55, .8 } })
  O.shade(c, c:ellipse(x + 2.5, y - 3, 2, 2), CH, { R = 1, amb = .35, sep = CH[1], cuts = { .3, .55, .8 } })
  O.flat(c, c:rect(x + 5, y - 3, x + 6, y - 3), ORG[3], "beak")
  O.dot(c, x + 3, y - 4, P.ink)
  O.dot(c, x - 3, y - 1, CH[4]) -- fuzz tuft tail
  O.flat(c, c:rect(x - 1, y + 3, x - 1, y + 3 - lift), ORG[3], "leg")
  O.flat(c, c:rect(x + 1, y + 3, x + 1, y + 3), ORG[3], "leg")
end
gosling(22, 51, 0)
gosling(14, 51, 0)
gosling(6, 50, 1)

O.shift(c, 0, 1)
O.done(c, "bb-gander-gait-yard")
