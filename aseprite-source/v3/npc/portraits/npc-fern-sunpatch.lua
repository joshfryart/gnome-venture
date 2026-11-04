-- npc-fern-sunpatch portrait (npc2 P1_11) species: tree frog
-- Same design as the sprite: plum hood with left-flopping tip + sun lining, bulging eyes, frog snout with nostrils, sunflower in hand. Lilac disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local INK, CREAM = "#2b1c26", "#fbf1d4"
local function F(c, m, r, band, pop)
  c:part(m, r, { band = band or 2, nopop = not pop, pop = pop and { x = math.floor(pop[1]), y = math.floor(pop[2]) } or nil })
  return m
end
local function under(c, m, hex)
  local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], hex) end
end
local function fuzz(m, list) for _, b in ipairs(list) do m:add(HP.ellipse(b[1], b[2], b[3] or 1.5, b[3] or 1.5)) end return m end
local function ring(cx, cy, rx, ry, a0, a1, st, r) local t = {} for a = a0, a1, st do local q = math.rad(a) t[#t + 1] = { cx + math.cos(q) * rx, cy + math.sin(q) * ry, r } end return t end
local function overlay(c, mask, r, from)
  local L = {}
  mask:each(function(x, y) local v = c:get(x, y)
    if v == from.base or v == from.hi then L[#L + 1] = { x, y, r.base } elseif v == from.shade then L[#L + 1] = { x, y, r.shade } elseif v == from.deep then L[#L + 1] = { x, y, r.deep } end end)
  for _, q in ipairs(L) do c:put(q[1], q[2], q[3]) end
end
local function lineOn(c, pts, hex, clipm) c:line(pts, 1):clip(clipm):each(function(x, y) c:put(x, y, hex) end) end
local NAME = "npc-fern-sunpatch"
local SKIN  = { hi = "#b8e06a", base = "#6fb84a", shade = "#3f7f4c", deep = "#2c4f4a" }
local BELLY = { hi = "#f8efc4", base = "#e8d898", shade = "#b9a47e", deep = "#7d6a6e" }
local HOOD  = { hi = "#b07ad0", base = "#7d4fa8", shade = "#563a86", deep = "#3a2862" }
local SUN   = { hi = "#ffeaa0", base = "#f5c64a", shade = "#cd8a3a", deep = "#8a563a" }
local SEED  = { hi = "#b0743e", base = "#7a4a32", shade = "#523248", deep = "#3a2433" }
local LEAF  = { hi = "#9fd35a", base = "#5a9a3c", shade = "#366b45", deep = "#24463f" }
local DISC  = { base = "#e2c8ee", shade = "#c7a6e0", deep = "#9f7cc4" }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local rg = disc:grow(1):cut(disc)
  rg:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- poncho shoulders + belly
local pm = c:ellipse(39.5, 100, 33, 32):clip(c:rect(0, 66, 79, 99))
F(c, pm, HOOD, 2, { 14, 86 })
lineOn(c, { { 22, 82 }, { 18, 99 } }, HOOD.shade, pm) lineOn(c, { { 57, 82 }, { 61, 99 } }, HOOD.deep, pm)
F(c, c:ellipse(39.5, 102, 10, 16):clip(c:rect(0, 78, 79, 99)), BELLY, 2, { 34, 88 })
-- hood with tip flopping left
local hm = c:ellipse(39.5, 47, 27, 24)
hm:add(c:line({ { 18, 32 }, { 10, 27 }, { 5, 34 } }, 6))
F(c, hm, HOOD, 3, { 22, 28 })
for _, q in ipairs{ { 23, 27 }, { 24, 27 }, { 25, 26 }, { 26, 26 }, { 23, 28 } } do c:px(q[1], q[2], HOOD.hi) end
under(c, hm, HOOD.deep)
F(c, c:ellipse(39.5, 55, 23, 17), SUN, 2, { 20, 48 })
-- head
local head = c:ellipse(39.5, 56, 20.5, 14)
F(c, head, SKIN, 3, { 24, 49 })
F(c, c:ellipse(39.5, 67, 12, 3.5):clip(head), BELLY, 1)
for _, ex in ipairs{ 30, 49 } do F(c, c:ellipse(ex, 40, 7, 6.5), SKIN, 2, { ex - 4, 36 }) end
c:eyeLocked(28, 38) c:eyeLocked(47, 38)
-- snout ridge + nostrils
F(c, c:ellipse(39.5, 52, 6, 2.5), SKIN, 1, { 36, 51 })
c:paint({ "N....N", "N....N" }, 37, 52, { N = "#2c4f4a" })
-- wide smile with lifted corners
c:paint({ "i......................i", ".i....................i.", "..iiiiiiiiiiiiiiiiiiii.." }, 28, 58, { i = "ink" })
c:paint({ "PPP", "PPP" }, 23, 58, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 58, { P = "petal.base" })
-- sunflower in hand
F(c, c:line({ { 63, 99 }, { 65, 78 }, { 66, 56 } }, 3), LEAF, 1)
F(c, c:poly{ { 65, 74 }, { 73, 68 }, { 75, 71 }, { 67, 77 } }, LEAF, 1, { 70, 69 })
F(c, c:ellipse(63, 86, 4.5, 3.5), SKIN, 2, { 61, 84 })
local pt = HP.mask()
for i = 0, 11 do local a = math.rad(i * 30) pt:add(c:ellipse(66 + math.cos(a) * 6.5, 48 + math.sin(a) * 6.5, 2.6, 2.6)) end
F(c, pt, SUN, 2, { 61, 42 })
F(c, c:ellipse(66, 48, 4.5, 4.5), SEED, 1, { 64, 46 })
for _, q in ipairs{ { 65, 49 }, { 67, 47 }, { 68, 50 }, { 64, 47 } } do c:px(q[1], q[2], SEED.shade) end
c:finish{ outline = true }
backdrop(DISC)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
