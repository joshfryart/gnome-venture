-- npc-nutmeg-rootstock portrait (npc2 P1_25) species: star-nosed mole
-- Same design as the sprite: pink star nose, brass spectacles, ribbed green beanie with a grafted sprig,
-- moss coat, pink digging paw gripping a dirt-tipped trowel (prop). Warm nutmeg-gold disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-nutmeg-rootstock"
local FUR = { hi = "#9a7f72", base = "#6e5852", shade = "#4c3c4a", deep = "#33263a" }
local MUZ = { hi = "#e3c3a8", base = "#b8937e", shade = "#8a6a6c", deep = "#5a4452" }
local HAND = { hi = P.cream, base = P.petal.hi, shade = P.petal.base, deep = P.petal.shade }
local COAT = P.moss
local CAP = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = "#1d3638" }
local BAND = { hi = P.moss.hi, base = P.moss.hi, shade = P.moss.base, deep = P.moss.shade }
local DISC = { base = P.gold.hi, shade = P.gold.base, deep = P.gold.shade }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- coat shoulders: front opening, buttons
local coat = c:ellipse(39.5, 106, 37, 32):clip(c:rect(0, 72, 79, 99))
c:part(coat, COAT, { band = 3 })
for y = 79, 99 do c:put(41, y, COAT.deep) end
c:part(c:rect(43, 84, 45, 86), P.gold, { band = 1, pop = { x = 43, y = 84 } })
c:part(c:rect(43, 93, 45, 95), P.gold, { band = 1, pop = { x = 43, y = 93 } })
-- trowel (prop) held up at the right: dirt-tipped blade, brass ferrule, wood grip
local blade = c:poly{ { 57, 71 }, { 67, 71 }, { 66, 63 }, { 62, 53 }, { 58, 63 } }
c:part(blade, P.stone, { band = 2, nopop = true })
c:fillMask(c:line({ { 59, 67 }, { 61, 58 } }, 1), P.stone.hi)
c:fillMask(c:line({ { 62, 57 }, { 62, 69 } }, 1), P.stone.base)
for _, q in ipairs{ { 62, 54 }, { 61, 55 }, { 62, 55 }, { 63, 56 }, { 61, 57 } } do c:put(q[1], q[2], P.wood.shade) end
c:put(62, 56, P.wood.base)
c:part(c:rect(59, 72, 65, 73), P.gold, { band = 1, pop = { x = 59, y = 72 } })
c:part(c:rrect(60, 74, 64, 92, 1), P.wood, { band = 1 })
for _, y in ipairs{ 77, 88 } do c:put(61, y, P.wood.shade) c:put(61, y + 1, P.wood.shade) end
-- collar
c:part(c:ellipse(39.5, 73, 17, 4), BAND, { band = 1, nopop = true })
-- head
local head = c:ellipse(39.5, 50, 21, 19)
c:part(head, FUR, { band = 3 })
for _, q in ipairs{ { 24, 56 }, { 22, 60 }, { 27, 64 }, { 53, 62 }, { 56, 58 }, { 50, 66 } } do
  c:put(q[1], q[2], FUR.hi) c:put(q[1] + 1, q[2] + 1, FUR.shade) end
-- beanie: ribbed crown + folded band
local E = c:ellipse(39.5, 49, 22.5, 20.5)
local crown = E:copy():clip(c:rect(0, 0, 79, 33))
local band = E:copy():clip(c:rect(0, 34, 79, 38))
c:part(crown, CAP, { band = 2, pop = { x = 27, y = 33 } })
local ci = crown:shrink(1)
for x = 21, 58, 3 do for y = 28, 33 do if ci:has(x, y) then c:put(x, y, CAP.shade) end end end
c:part(band, BAND, { band = 2 })
for x = 19, 60, 2 do if band:shrink(1):has(x, 36) then c:put(x, 36, P.moss.base) end end
-- grafted sprig on the crown: twig, twine wrap, two leaves
c:part(c:line({ { 40, 29 }, { 41, 24 }, { 44, 20 } }, 2), P.wood, { band = 1, nopop = true })
c:part(c:rect(40, 25, 42, 26), P.gold, { band = 1, nopop = true })
c:part(c:ellipse(47.5, 18.5, 3.5, 1.8), P.moss, { band = 1, pop = { x = 45, y = 18 } })
c:part(c:ellipse(37, 21, 2.5, 1.5), P.moss, { band = 1, nopop = true })
c:put(46, 19, P.moss.shade) c:put(48, 19, P.moss.shade)
-- muzzle
c:part(c:ellipse(39.5, 58, 12, 8), MUZ, { band = 2, nopop = true })
-- star nose: 12 fleshy rays around a round snout tip
for i = 0, 11 do
  local a = math.rad(i * 30 + 15)
  local m = c:line({ { 39.5 + math.cos(a) * 2.5, 57.5 + math.sin(a) * 2.5 }, { 39.5 + math.cos(a) * 6, 57.5 + math.sin(a) * 6 } }, 1)
  c:fillMask(m, P.petal.base)
  local tx, ty = math.floor(39.5 + math.cos(a) * 6), math.floor(57.5 + math.sin(a) * 6)
  c:put(tx, ty, (math.cos(a) < 0 and math.sin(a) < 0) and P.petal.hi or P.petal.shade)
end
c:part(c:ellipse(39.5, 57.5, 3, 2.5), P.petal, { band = 1, pop = { x = 38, y = 56 } })
c:put(38, 58, P.petal.deep) c:put(41, 58, P.petal.deep)
-- small smile
c:paint({ "i....i", ".iiii." }, 37, 65, { i = "ink" })
c:paint({ "PPP" }, 22, 53, { P = "petal.base" }) c:paint({ "PPP" }, 55, 53, { P = "petal.base" })
-- locked eyes behind round brass spectacles
for _, x in ipairs{ 27, 48 } do
  c:eyeLocked(x, 43)
  local ring = c:ellipse(x + 2.5, 45.5, 4.6, 4.6):cut(c:ellipse(x + 2.5, 45.5, 3.6, 3.6))
  ring:each(function(rx, ry) c:put(rx, ry, (rx <= x + 1 and ry <= 44) and P.gold.hi or P.gold.shade) end)
end
for x = 34, 45 do c:put(x, 44, P.gold.shade) end
c:fillMask(c:line({ { 23, 44 }, { 19, 43 } }, 1), P.gold.shade)
c:fillMask(c:line({ { 56, 44 }, { 60, 43 } }, 1), P.gold.shade)
-- paw gripping the trowel handle, cream claws
c:part(c:ellipse(61.5, 83, 5, 4.5), HAND, { band = 1, pop = { x = 59, y = 80 } })
for _, y in ipairs{ 81, 84 } do c:put(60, y, HAND.shade) c:put(61, y, HAND.shade) end
for _, q in ipairs{ { 56, 81 }, { 56, 84 }, { 57, 87 } } do c:put(q[1], q[2], P.cream) end
c:finish{ outline = true }
backdrop(DISC)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
