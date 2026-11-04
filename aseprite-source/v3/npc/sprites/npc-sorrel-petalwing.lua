-- npc-sorrel-petalwing sprite (npc2 P1_34) species: tawny owl
-- Sorrel Petalwing, the flower-keeping owl: rose petal hood with scalloped rim and leaf sprig, ear tufts poking
-- through, heart face disc, rose scarf. prop: a daisy held in the right wing. 64x96 cell, feet baseline y=90, idle(4).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-sorrel-petalwing"
local FEA = P.wood
local WING = { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = "#3a221f" }
local HOOD = { hi = P.petal.base, base = P.petal.shade, shade = P.petal.deep, deep = "#4e1c40" }
local CR = { hi = P.cream, base = P.cream, shade = P.skinA.hi, deep = P.skinA.base }
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg) local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.bob or 0
  c:groundShadow(32, 89.5, 13, 3)
  -- body + belly chevrons
  c:part(c:ellipse(32, 72 + b, 13, 14), FEA, { band = 2, pop = { x = 24, y = 63 + b } })
  c:part(c:ellipse(32, 76 + b, 8, 9), CR, { band = 1, nopop = true })
  for _, y in ipairs{ 71, 75, 79 } do for x = 27, 35, 4 do
    c:put(x, y + b, FEA.hi) c:put(x + 1, y + 1 + b, FEA.base) c:put(x + 2, y + b, FEA.hi) end end
  -- wings
  c:part(oval(20, 71 + b, 9, 4, 80), WING, { band = 1, nopop = true })
  c:part(oval(44, 71 + b, 9, 4, 100), WING, { band = 1, nopop = true })
  -- daisy in the right wing
  local fx = p.fx or 0
  c:fillMask(c:line({ { 45, 74 + b }, { 48 + fx, 61 + b } }, 1), P.moss.shade)
  for i = 0, 4 do local a = math.rad(-90 + i * 72)
    c:part(c:ellipse(48 + fx + math.cos(a) * 2.5, 58 + b + math.sin(a) * 2.5, 1.5, 1.5), CR, { band = 1, nopop = true }) end
  c:fillMask(c:rect(47 + fx, 57 + b, 48 + fx, 58 + b), P.gold.base) c:put(47 + fx, 57 + b, P.gold.hi)
  -- talons (never move)
  for _, x in ipairs{ 27, 37 } do
    c:part(c:ellipse(x, 88, 2.5, 1.5), P.gold, { band = 1, nopop = true })
    c:put(x - 1, 89, P.gold.deep) c:put(x + 1, 89, P.gold.deep)
  end
  -- scarf
  c:part(c:rrect(21, 55 + b, 43, 59 + b, 2), HOOD, { band = 1, nopop = true })
  c:part(c:line({ { 39, 59 + b }, { 41 + (p.tail or 0), 67 + b } }, 3), HOOD, { band = 1, nopop = true })
  -- head, face disc
  local head = c:ellipse(32, 41 + b, 16, 14)
  c:part(head, FEA, { band = 2, pop = { x = 20, y = 38 + b } })
  local face = c:ellipse(26.5, 44 + b, 6, 6):add(c:ellipse(37.5, 44 + b, 6, 6)):clip(head)
  c:part(face, CR, { band = 1, nopop = true })
  -- rose hood
  local hood = head:copy():clip(c:rect(0, 0, 63, 36 + b))
  for x = 17, 47, 5 do hood:add(c:ellipse(x, 36 + b, 2.5, 2):clip(head:grow(1))) end
  local tp = p.tip or 0
  hood:add(c:poly{ { 26, 30 + b }, { 32 + tp, 21 + b }, { 38, 30 + b } })
  c:part(hood, HOOD, { band = 2, pop = { x = 22, y = 31 + b } })
  c:stitch{ { 19, 35 + b }, { 45, 35 + b } }
  -- ear tufts poking through
  c:part(c:poly{ { 17, 33 + b }, { 14, 24 + b }, { 22, 29 + b } }, FEA, { band = 1, nopop = true })
  c:part(c:poly{ { 47, 33 + b }, { 50, 24 + b }, { 42, 29 + b } }, FEA, { band = 1, nopop = true })
  -- leaf sprig
  c:part(oval(40 + tp, 26 + b, 4, 2, -30), P.moss, { band = 1, nopop = true })
  -- eyes, brows, beak
  if p.blink then for i = 0, 4 do c:put(24 + i, 43 + b, P.ink) c:put(35 + i, 43 + b, P.ink) end
  else c:eyeLocked(24, 41 + b) c:eyeLocked(35, 41 + b) end
  c:put(24, 40 + b, FEA.deep) c:put(25, 40 + b, FEA.deep) c:put(38, 40 + b, FEA.deep) c:put(39, 40 + b, FEA.deep)
  c:part(c:poly{ { 30, 47 + b }, { 34, 47 + b }, { 32, 51 + b } }, P.gold, { band = 1, nopop = true })
  c:put(30, 47 + b, P.gold.hi)
  c:cheek(21, 48 + b) c:cheek(41, 48 + b)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local F = { { bob = 0 }, { bob = 1, tip = 1, tail = 1 }, { bob = 0 }, { bob = 0, blink = true, fx = 1 } }
local frames = {}
for _, p in ipairs(F) do frames[#frames + 1] = frame(p) end
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
