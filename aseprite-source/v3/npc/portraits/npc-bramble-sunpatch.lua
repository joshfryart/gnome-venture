-- npc-bramble-sunpatch portrait (npc2 P1_3) species: ladybug
-- Same design as the sprite: red spotted head under a green leaf cap, knobbed antennae, red spotted
-- wing-shell cape over a gold smock with cream V collar, sunflower in frame. Gold backdrop disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-bramble-sunpatch"
local DK = { hi = P.dusk.shade, base = P.dusk.deep, shade = "#251c42", deep = "#1e1630" }
local PET = { hi = P.cream, base = P.gold.hi, shade = P.gold.base, deep = P.gold.shade }
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local function R(v) return math.floor(v + 0.5) end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function under(m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function spot(x, y) c:paint({ ".hb.", "hbbb", "bbbb", ".bb." }, x, y, { h = DK.hi, b = DK.base }) end
-- wing-shell cape on the shoulders
for _, s in ipairs{ { 15, false }, { 64, true } } do
  local m = c:ellipse(s[1], 94, 11, 14):clip(c:rect(0, 0, 79, 99))
  c:part(m, P.ember, { band = 2, nopop = s[2], pop = { x = 8, y = 84 } })
end
spot(7, 87) spot(12, 95) spot(67, 86) spot(70, 95)
-- smock
local body = c:ellipse(39.5, 102, 24, 26):clip(c:rect(0, 0, 79, 99))
c:part(body, P.gold, { band = 3, pop = { x = 22, y = 86 } })
c:part(c:poly{ { 30, 76 }, { 49, 76 }, { 39, 86 } }, CR, { band = 1, nopop = true })
for y = 88, 98, 2 do c:put(39, y, P.gold.shade) end
c:part(c:rect(35, 66, 44, 77), DK, { band = 1, nopop = true })
-- head
local hd = c:ellipse(39.5, 52, 20, 16)
c:part(hd, P.ember, { band = 3, pop = { x = 25, y = 43 } })
for _, q in ipairs{ { 26, 43 }, { 27, 44 } } do c:put(q[1], q[2], P.ember.hi) end
spot(21, 49) spot(55, 50)
c:eyeLocked(29, 49) c:eyeLocked(46, 49)
local ns = c:ellipse(39.5, 57, 2.5, 1.5)
c:part(ns, P.ember, { band = 1, sep = true, pop = { x = 38, y = 56 } })
under(ns, P.ember.deep)
c:paint({ "i.....i", ".iiiii.", "..iPi.." }, 36, 60, { i = "ink", P = "petal.base" })
c:paint({ "PPh", "PPP" }, 25, 57, { P = "petal.base", h = "petal.hi" }) c:paint({ "hPP", "PPP" }, 51, 57, { P = "petal.base", h = "petal.hi" })
-- leaf cap
local lf = c:poly{ { 14, 39 }, { 22, 31 }, { 39, 28 }, { 54, 29 }, { 66, 35 }, { 57, 41 }, { 40, 42 }, { 22, 42 } }
c:part(lf, P.moss, { band = 2, pop = { x = 22, y = 33 } })
under(lf, P.moss.deep)
c:line({ { 17, 39 }, { 40, 35 }, { 63, 35 } }, 1):clip(lf):each(function(x, y) c:put(x, y, P.moss.deep) end)
for _, v in ipairs{ { 24, 38, 21, 34 }, { 32, 36, 29, 32 }, { 44, 35, 42, 31 }, { 53, 35, 52, 31 }, { 28, 37, 26, 40 }, { 48, 35, 47, 39 } } do
  c:line({ { v[1], v[2] }, { v[3], v[4] } }, 1):clip(lf:shrink(1)):each(function(x, y) c:put(x, y, P.moss.shade) end)
end
c:part(c:line({ { 40, 29 }, { 41, 25 }, { 44, 23 } }, 2), P.wood, { band = 1, nopop = true })
-- sunflower
c:part(c:line({ { 70, 99 }, { 68, 88 }, { 66, 78 } }, 3), P.moss, { band = 1, nopop = true })
c:part(c:ellipse(72, 89, 4, 2), P.moss, { band = 1, sep = true, pop = { x = 70, y = 88 } })
local fm = c:ellipse(66, 70, 7, 7)
for i = 0, 11 do local a = math.rad(i * 30 + 8) fm:add(c:ellipse(66 + math.cos(a) * 7, 70 + math.sin(a) * 7, 1.6, 1.6)) end
c:part(fm, PET, { band = 2, pop = { x = 59, y = 67 } })
local ctr = c:ellipse(66, 70, 3.5, 3.5)
c:part(ctr, P.wood, { band = 1, sep = true, pop = { x = 64, y = 68 } })
under(ctr, P.wood.deep)
for _, q in ipairs{ { 66, 70 }, { 68, 69 }, { 65, 72 }, { 67, 72 } } do c:put(q[1], q[2], P.wood.deep) end
-- antenna knobs
for _, x in ipairs{ 22, 58 } do c:part(c:ellipse(x, 12, 2.5, 2.5), DK, { band = 1, pop = { x = x - 1, y = 10 } }) end
c:finish{ outline = true }
c:fillMask(c:line({ { 31, 29 }, { 26, 21 }, { 23, 15 } }, 1), P.ink)
c:fillMask(c:line({ { 48, 28 }, { 53, 21 }, { 57, 15 } }, 1), P.ink)
backdrop(P.gold)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
