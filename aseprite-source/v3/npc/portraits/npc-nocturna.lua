-- npc-nocturna portrait (npc2 P1_24) species: lilac moth
-- Same design as the sprite: fluffy lilac moth, violet forewings with gold eyespots, rosy hindwings,
-- straw sun-hat with violet ribbon, feathery antennae, cream ruff. Prop: glowing lantern. Mint backdrop.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-nocturna"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local R = {
  fur   = { hi = "#ead0ec", base = "#c49ad2", shade = "#8c6aa9", deep = "#5d4581" },
  wing  = { hi = "#b49ae8", base = "#8a6bcb", shade = "#5f4aa0", deep = "#3e3274" },
  rib   = { hi = "#f4b6cc", base = "#d9799e", shade = "#a24f86", deep = "#6c3266" },
  gold  = { hi = "#ffe38c", base = "#f3b53f", shade = "#c97b2c", deep = "#8b4b2c" },
  straw = { hi = "#f8e4a2", base = "#e0bc69", shade = "#b4894b", deep = "#7a5639" },
  ruff  = { hi = "#fff2da", base = "#f1dab6", shade = "#c8a8aa", deep = "#8e7492" },
  leg   = { hi = "#8a6a96", base = "#654a76", shade = "#47355c", deep = "#352745" },
  bg    = { base = "#7cc6b4", shade = "#55a092", deep = "#3c7a74" },
}
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function mir(t) local o = {} for i, q in ipairs(t) do o[i] = { 79 - q[1], q[2] } end return o end
-- hindwings
for _, s in ipairs{ -1, 1 } do c:part(c:ellipse(39.5 + s * 29, 89, 8, 7), R.rib, { band = 2, pop = { x = s < 0 and 7 or 66, y = 85 } }) end
-- forewings
for _, s in ipairs{ -1, 1 } do
  local L = { { 30, 74 }, { 10, 46 }, { 3, 52 }, { 2, 66 }, { 8, 78 }, { 24, 82 } }
  local v1, v2, v3 = { { 28, 75 }, { 8, 52 } }, { { 27, 78 }, { 4, 67 } }, { { 25, 80 }, { 9, 77 } }
  if s > 0 then L, v1, v2, v3 = mir(L), mir(v1), mir(v2), mir(v3) end
  local m = c:poly(L)
  c:part(m, R.wing, { band = 2, pop = { x = s < 0 and 7 or 70, y = 52 } })
  for _, v in ipairs{ v1, v2, v3 } do c:fillMask(c:line(v, 1):clip(m:shrink(1)), R.wing.shade) end
  local ex = s < 0 and 11.5 or 68
  c:part(c:ellipse(ex, 63, 4, 4), R.gold, { band = 1, nopop = true })
  c:fillMask(c:ellipse(ex, 63, 1.5, 1.5), R.wing.deep)
  c:put(math.floor(ex) - 2, 61, R.gold.hi)
end
-- body with rosy stripes
local body = c:ellipse(39.5, 106, 25, 30):clip(c:rect(0, 70, 79, 99))
c:part(body, R.fur, { band = 3, pop = { x = 22, y = 84 } })
for _, y in ipairs{ 88, 95 } do
  c:rect(0, y, 79, y + 2):clip(body):each(function(x, yy)
    local v = c:get(x, yy)
    c:put(x, yy, (v == R.fur.shade or v == R.fur.deep) and R.rib.shade or R.rib.base)
  end)
end
for _, q in ipairs{ { 24, 80 }, { 29, 83 }, { 33, 79 }, { 21, 86 }, { 45, 81 }, { 27, 92 } } do if body:has(q[1], q[2]) then c:put(q[1], q[2], R.fur.hi) end end
-- ruff
local ruff = c:ellipse(39.5, 71, 16, 4)
for _, q in ipairs{ { 25, 74 }, { 30, 75.5 }, { 36, 76 }, { 43, 76 }, { 49, 75.5 }, { 54, 74 } } do ruff:add(c:ellipse(q[1], q[2], 2, 2)) end
c:part(ruff, R.ruff, { band = 1, pop = { x = 27, y = 69 } })
-- head
local head = c:ellipse(39.5, 52, 20, 15.5)
for _, q in ipairs{ { 19.5, 55 }, { 20.5, 60 }, { 59.5, 55 }, { 58.5, 60 } } do head:add(c:ellipse(q[1], q[2], 2, 2)) end
c:part(head, R.fur, { band = 3, pop = { x = 25, y = 46 } })
for _, q in ipairs{ { 23, 50 }, { 26, 59 }, { 54, 50 }, { 22, 57 } } do c:put(q[1], q[2], R.fur.hi) end
c:eyeLocked(29, 48) c:eyeLocked(46, 48)
-- fuzzy rosy nose + smile + cheeks
c:part(c:ellipse(39.5, 56, 2.5, 1.5), R.rib, { band = 1, nopop = true, inner = false })
c:put(38, 55, R.rib.hi)
for _, q in ipairs{ { 36, 59 }, { 37, 60 }, { 38, 60 }, { 39, 60 }, { 40, 60 }, { 41, 60 }, { 42, 59 } } do c:put(q[1], q[2], P.ink) end
c:put(39, 61, R.rib.base) c:put(40, 61, R.rib.base)
for _, x0 in ipairs{ 24, 52 } do for x = x0, x0 + 2 do c:put(x, 57, R.rib.hi) c:put(x, 58, R.rib.hi) end end
-- straw hat
local brim = c:ellipse(39.5, 37, 27, 5.5)
brim:add(c:ellipse(14, 39.5, 3, 2)) brim:add(c:ellipse(65, 39.5, 3, 2))
c:part(brim, R.straw, { band = 2, pop = { x = 17, y = 35 } })
for x = 15, 64, 3 do for _, y in ipairs{ 39, 40 } do if brim:has(x, y) and c:get(x, y) == R.straw.base:lower() then c:put(x, y, R.straw.shade) end end end
local crown = c:rrect(28, 19, 51, 37, 6)
c:part(crown, R.straw, { band = 2, pop = { x = 31, y = 22 } })
crown:each(function(x, y) if (x + y) % 3 == 0 and y < 32 and c:get(x, y) == R.straw.base:lower() then c:put(x, y, R.straw.shade) end end)
c:part(c:rect(28, 31, 51, 35):clip(crown), R.wing, { band = 1, nopop = true })
local bow = c:ellipse(25, 34, 3, 2) bow:add(c:ellipse(21, 35.5, 2, 2))
c:part(bow, R.rib, { band = 1, nopop = true })
-- feathery antennae
for _, s in ipairs{ -1, 1 } do
  local a = { { 33, 21 }, { 26, 12 }, { 19, 4 }, { 22, 1 }, { 29, 9 }, { 37, 20 } }
  if s > 0 then a = mir(a) end
  local m = c:poly(a)
  c:part(m, R.leg, { band = 1, nopop = true, inner = false })
  m:each(function(x, y) if (x + y) % 2 == 0 and c:get(x, y) == R.leg.base:lower() then c:put(x, y, R.leg.hi) end end)
end
-- lantern held in the right paw
c:part(c:rect(63, 80, 65, 83), R.leg, { band = 1, nopop = true })
c:part(c:rect(58, 84, 70, 86), R.leg, { band = 1, nopop = true })
c:part(c:rrect(59, 87, 69, 97, 2), R.gold, { band = 2, pop = { x = 60, y = 88 } })
for y = 87, 97 do c:put(64, y, R.gold.shade) end
c:fillMask(c:ellipse(61.5, 92, 1.5, 2.5), R.gold.hi) c:put(61, 91, R.ruff.hi)
c:part(c:rect(58, 98, 70, 99), R.leg, { band = 1, nopop = true })
c:part(c:ellipse(64, 79, 3.5, 3), R.fur, { band = 1, nopop = true })
c:finish{ outline = true }
backdrop(R.bg)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
