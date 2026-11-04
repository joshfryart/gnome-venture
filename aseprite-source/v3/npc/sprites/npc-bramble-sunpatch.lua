-- npc-bramble-sunpatch sprite (npc2 P1_3) species: ladybug
-- Bramble Sunpatch: cheerful ladybug gardener. Round red spotted head under a green leaf cap, knobbed antennae,
-- red spotted wing-shell worn like a cape over a sunny gold smock. Prop: a sunflower she carries on her right.
-- 64x96 cell, feet baseline y=90, idle 4 frames (base, breath + antennae settle, base, blink + flower nod).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-bramble-sunpatch"
local DK = { hi = P.dusk.shade, base = P.dusk.deep, shade = "#251c42", deep = "#1e1630" }
local PET = { hi = P.cream, base = P.gold.hi, shade = P.gold.base, deep = P.gold.shade }
local CR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local function R(v) return math.floor(v + 0.5) end
local function under(c, m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local function eye(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, P.ink) end return end
  c:put(x + 1, y, P.ink) c:put(x + 2, y, P.ink)
  for _, q in ipairs{ {0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function spot(c, x, y) c:paint({ "hb", "bb" }, x, y, { h = DK.hi, b = DK.base }) end
local function flower(c, cx, cy, r)
  local m = c:ellipse(cx, cy, r - 1, r - 1)
  for i = 0, 9 do local a = math.rad(i * 36 + 10) m:add(c:ellipse(cx + math.cos(a) * (r - 1), cy + math.sin(a) * (r - 1), 1.5, 1.5)) end
  c:part(m, PET, { band = 1, pop = { x = R(cx - r + 1), y = R(cy - 2) } })
  local ctr = c:ellipse(cx, cy, r * 0.45, r * 0.45)
  c:part(ctr, P.wood, { band = 1, sep = true, pop = { x = R(cx) - 1, y = R(cy) - 1 } })
  under(c, ctr, P.wood.deep)
end

local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b, fx = p.bob or 0, p.fx or 0
  local ad = b + (p.ad or 0)
  c:groundShadow(32, 89.5, 12, 3)
  for _, x in ipairs{ 27, 37.5 } do
    local m = c:ellipse(x, 88, 3, 2) c:part(m, DK, { band = 1, pop = { x = R(x) - 2, y = 87 } }) under(c, m, DK.deep)
  end
  -- wing-shell cape halves
  for _, s in ipairs{ { 21, false }, { 43, true } } do
    local m = c:ellipse(s[1], 74 + b, 7, 10)
    c:part(m, P.ember, { band = 2, nopop = s[2], pop = { x = s[1] - 5, y = 69 + b } })
    under(c, m, P.ember.deep)
  end
  spot(c, 15, 72 + b) spot(c, 17, 79 + b) spot(c, 47, 72 + b) spot(c, 45, 80 + b)
  -- gold smock with cream V collar
  local sm = c:ellipse(32, 78 + b, 10, 9):clip(c:rect(0, 0, 63, 86))
  c:part(sm, P.gold, { band = 2, pop = { x = 24, y = 73 + b } })
  sm:each(function(x, y) if not sm:has(x, y + 1) then c:put(x, y, P.gold.deep) end end)
  c:part(c:poly{ { 27, 69 + b }, { 37, 69 + b }, { 32, 74 + b } }, CR, { band = 1, nopop = true })
  for y = 77, 84, 2 do c:put(32, y + b, P.gold.shade) end
  c:part(c:ellipse(22.5, 79 + b, 2, 2.5), DK, { band = 1, pop = { x = 21, y = 78 + b } })
  -- sunflower (prop) held in the right hand
  local stem = c:line({ { 42, 81 + b }, { 45, 71 + b }, { 49 + fx, 60 + b } }, 2)
  c:part(stem, P.moss, { band = 1, nopop = true })
  c:part(c:ellipse(47, 71 + b, 2.5, 1.5), P.moss, { band = 1, sep = true, pop = { x = 45, y = 70 + b } })
  c:part(c:ellipse(41.5, 79 + b, 2, 2.5), DK, { band = 1, nopop = true })
  -- head
  local hd = c:ellipse(32, 54 + b, 13, 11)
  c:part(hd, P.ember, { band = 3, pop = { x = 22, y = 49 + b } })
  spot(c, 20, 56 + b) spot(c, 42, 57 + b)
  eye(c, 25, 52 + b, p.blink) eye(c, 36, 52 + b, p.blink)
  c:paint({ "h.", "ss" }, 31, 57 + b, { h = P.ember.hi, s = P.ember.deep })
  c:paint({ "i....i", ".iiii." }, 29, 60 + b, { i = "ink" })
  c:cheek(23, 58 + b) c:cheek(39, 58 + b)
  -- leaf cap with midrib and a stem nub
  local lf = c:poly{ { 16, 47 + b }, { 22, 42 + b }, { 32, 40 + b }, { 42, 41 + b }, { 48, 44 + b }, { 42, 47 + b }, { 32, 48 + b }, { 22, 48 + b } }
  c:part(lf, P.moss, { band = 2, pop = { x = 23, y = 43 + b } })
  under(c, lf, P.moss.deep)
  c:line({ { 19, 46 + b }, { 32, 44 + b }, { 45, 44 + b } }, 1):clip(lf):each(function(x, y) c:put(x, y, P.moss.deep) end)
  for _, v in ipairs{ { 25, 45, 23, 43 }, { 31, 44, 29, 42 }, { 38, 44, 37, 42 } } do c:put(v[3] + 1, v[4] + 1 + b, P.moss.shade) end
  c:part(c:rect(32, 37 + b, 33, 40 + b), P.wood, { band = 1, nopop = true })
  -- flower head over the cap edge
  flower(c, 50 + fx, 56 + b, 6)
  -- antenna knobs (stalks drawn after outline)
  for _, x in ipairs{ 23, 41 } do c:part(c:ellipse(x, 31 + ad, 1.5, 1.5), DK, { band = 1, pop = { x = x - 1, y = 30 + ad }, horizontal = false }) end
  c:finish{ outline = true }
  c:fillMask(c:line({ { 27, 40 + b }, { 25, 36 + ad }, { 23, 33 + ad } }, 1), P.ink)
  c:fillMask(c:line({ { 37, 40 + b }, { 39, 36 + ad }, { 41, 33 + ad } }, 1), P.ink)
  HP.assertClean(c)
  return c
end
local F = { {}, { bob = 1, ad = 1 }, {}, { blink = true, fx = 1 } }
local fr = {}
for _, p in ipairs(F) do fr[#fr + 1] = frame(p) end
HP.report(fr[1])
HP.sheet{ cellw = 64, cellh = 96, frames = fr, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
