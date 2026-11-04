-- npc-auntie-mossbead portrait (npc2 P1_0) species: tortoise
-- Same design as the sprite: olive speckled elder tortoise, mossy shell rim behind the shoulders, horn beak,
-- violet gold-dotted headwrap with moss sprig, bead necklace, teal basket of red berries. Moss backdrop disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-auntie-mossbead"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local SKIN = { hi = "#cfdc8e", base = "#94ae5e", shade = "#5f7f5c", deep = "#36504e" }
local PLAS = { hi = "#fff0b0", base = "#ecd27a", shade = "#bf9a5a", deep = "#7a5a44" }
local HORN = { hi = "#f6e6b4", base = "#d9b56e", shade = "#a07a54", deep = "#5e4440" }
local SHELL, WRAP, BASK = P.wood, P.dusk, P.sea
local function D(x, y, hex) c:put(x, y, hex, c.own[y * c.w + x] or "d") end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- shell dome behind the shoulders
local sh = c:ellipse(39.5, 99, 36, 27):clip(c:rect(0, 0, 79, 99))
c:part(sh, SHELL, { band = 3 })
c:ellipse(39.5, 102, 27, 19):edge():clip(sh):each(function(x, y) D(x, y, SHELL.deep) end)
for _, l in ipairs{ { {17,88},{8,84} }, { {62,88},{71,84} }, { {28,84},{24,76} }, { {51,84},{55,76} } } do
  c:line(l, 1):clip(sh):each(function(x, y) D(x, y, SHELL.deep) end) end
local mo = HP.mask()
for _, q in ipairs{ {7,86,4,3.5},{13,78,4,3.5},{22,74,3.5,3},{57,74,3.5,3},{66,78,4,3.5},{72,86,4,3.5} } do mo:add(HP.ellipse(q[1], q[2], q[3], q[4])) end
c:part(mo, P.moss, { band = 1, pop = { 11, 76 } })
for _, q in ipairs{ {6,85},{14,77},{21,73},{56,73},{65,77},{71,85} } do D(q[1], q[2], P.moss.hi) end
-- neck + plastron
c:part(c:rect(28, 62, 51, 88), SKIN, { band = 2, nopop = true })
for _, q in ipairs{ {32,70,36},{43,70,47},{34,74,38},{41,74,45} } do for x = q[1], q[3] do D(x, q[2], SKIN.shade) end end
local pl = c:ellipse(39.5, 106, 24, 21):clip(c:rect(0, 0, 79, 99))
c:part(pl, PLAS, { band = 2 })
pl:each(function(x, y) if (x == 39 or y == 93) and c:get(x, y) ~= P.ink then D(x, y, PLAS.shade) end end)
-- bead necklace
local cols = { P.ember, P.gold, P.moss }
for i = 0, 7 do
  local t = i / 7
  local x, y = 20 + t * 39, 77 + math.floor(5 * math.sin(math.pi * t) + .5)
  c:part(HP.ellipse(x, y, 2.6, 2.6), cols[i % 3 + 1], { nopop = true, band = 1 })
  D(math.floor(x) - 1, y - 2, P.cream)
end
-- basket of berries (prop)
for _, q in ipairs{ {50,88},{55,87},{60,88},{65,89},{53,90},{58,90},{62,90} } do
  c:part(HP.ellipse(q[1], q[2], 2.5, 2.5), P.ember, { nopop = true, band = 1 })
  D(q[1] - 2, q[2] - 2, P.ember.hi) D(q[1] - 1, q[2] - 2, P.ember.hi)
end
local bowl = c:ellipse(57.5, 92, 13.5, 7):clip(c:rect(0, 91, 79, 99))
c:part(bowl, BASK, { band = 2, nopop = true })
bowl:each(function(x, y) if y > 92 and (x + y * 2) % 4 == 0 and c:get(x, y) == BASK.base then D(x, y, BASK.shade) end end)
for x = 44, 71 do if bowl:has(x, 91) and x % 2 == 0 then D(x, 91, BASK.hi) end end
c:part(c:ellipse(44, 92, 3.5, 3), SKIN, { nopop = true })
c:part(c:ellipse(71, 92, 3.5, 3), SKIN, { nopop = true })
-- head
local head = c:ellipse(39.5, 51, 21, 16)
c:part(head, SKIN, { band = 3, pop = { 24, 47 } })
for _, q in ipairs{ {23,54},{26,57},{29,59},{51,58},{55,55},{57,50},{21,50},{48,61} } do if c:get(q[1], q[2]) == SKIN.base or c:get(q[1], q[2]) == SKIN.shade then D(q[1], q[2], SKIN.hi) end end
-- wide gentle mouth line + horn beak
for _, q in ipairs{ {24,59},{25,60},{26,60},{27,61},{28,61},{29,61},{30,62},{31,62},{32,62},{33,62} } do D(q[1], q[2], SKIN.deep) D(79 - q[1], q[2], SKIN.deep) end
c:part(c:poly{ {34,57},{45,57},{44,62},{39.5,67},{35,62} }, HORN, { band = 2, pop = { 36, 58 } })
D(37, 59, HORN.deep) D(42, 59, HORN.deep) D(39, 66, HORN.shade) D(40, 66, HORN.shade)
-- eyes with heavy kind lids
c:eyeLocked(27, 47) c:eyeLocked(48, 47)
for x = 27, 31 do D(x, 46, SKIN.shade) end for x = 48, 52 do D(x, 46, SKIN.shade) end
D(26, 47, SKIN.deep) D(53, 47, SKIN.deep)
for x = 28, 30 do D(x, 53, SKIN.shade) end for x = 49, 51 do D(x, 53, SKIN.shade) end
for _, q in ipairs{ {21,56},{22,56},{23,57},{56,56},{57,56},{56,57} } do D(q[1], q[2], P.petal.base) end
-- headwrap, gold hem, dots, knot + moss sprig
local wr = c:ellipse(39.5, 38, 23, 9.5)
local knot = c:ellipse(53, 23, 8.5, 7.5)
local all = wr:copy():add(knot)
c:part(all, WRAP, { band = 3, pop = { 22, 33 } })
for x = 16, 63 do local ly
  for y = 28, 48 do if wr:has(x, y) then ly = y end end
  if ly then D(x, ly, x > 50 and P.gold.shade or P.gold.base) D(x, ly - 1, P.gold.shade) end
end
all:each(function(x, y) local v = c:get(x, y) if (x * 3 + y * 5) % 11 == 0 and (v == WRAP.base or v == WRAP.hi) then D(x, y, P.gold.hi) end end)
for _, l in ipairs{ { {26,32},{34,42} }, { {42,31},{52,41} }, { {48,24},{56,28} } } do c:line(l, 1):clip(all):each(function(x, y) D(x, y, WRAP.deep) end) end
local sprig = HP.ellipse(55, 14, 3.5, 2.5)
sprig:add(HP.poly{ {50,15},{47,10},{53,12} }) sprig:add(HP.poly{ {59,14},{63,9},{58,11} })
c:part(sprig, P.moss, { band = 1, pop = { 52, 12 } })
c:part(HP.ellipse(55.5, 13.5, 1.5, 1.5), P.gold, { nopop = true }) D(55, 13, P.cream)
c:finish{ outline = true }
backdrop(P.moss)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
