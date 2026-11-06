-- npc-oakley-mossfoot portrait (npc2 P1_26) species: dragonfly
local NAME = "npc-oakley-mossfoot"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local INK, CREAM = "#2b1c26", "#f4ead0"
local function eye4(c, x, y, blink)
  if blink then for i = 0, 3 do c:put(x + i, y + 2, INK) end return end
  c:put(x + 1, y, INK) c:put(x + 2, y, INK)
  for _, q in ipairs({ { 0, 1 }, { 3, 1 }, { 0, 2 }, { 3, 2 }, { 1, 3 }, { 2, 3 }, { 1, 1 } }) do c:put(x + q[1], y + q[2], CREAM) end
  c:put(x + 2, y + 1, INK) c:put(x + 1, y + 2, INK) c:put(x + 2, y + 2, INK)
end
local function recol(c, m, from, to) m:each(function(x, y) if c:get(x, y) == from then c:put(x, y, to) end end) end
local BLUE  = { hi = "#7fc8e0", base = "#3f8fc0", shade = "#2f5f9a", deep = "#2c3c72" }
local EYEG  = { hi = "#b8e070", base = "#6fae3a", shade = "#3f7a3a", deep = "#2c4c3a" }
local WING  = { hi = "#eef4ea", base = "#cfe6ee", shade = "#9cc0d8", deep = "#6f8cb8" }
local STRAW = { hi = "#f6d47a", base = "#e0a83c", shade = "#b0702e", deep = "#7a4630" }
local PURP  = { hi = "#a882d8", base = "#7650b0", shade = "#523a8a", deep = "#3a2a62" }
local CLOAK = { hi = "#b88a5a", base = "#8a5e3c", shade = "#5e3c34", deep = "#3e2830" }
local MOSS  = { hi = "#b6d65a", base = "#6e9e38", shade = "#44702e", deep = "#2e4a2c" }
local function backdrop(c, r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
-- wings sticking out sideways behind the head
for _, s in ipairs{ -1, 1 } do
  local up = oval(40 + s * 27, 48, 12, 3.6, s * -8)
  local lo = oval(40 + s * 25, 59, 10, 3, s * 10)
  c:part(lo, WING, { band = 1, nopop = true })
  c:part(up, WING, { band = 2, nopop = true })
  c:fillMask(c:line({ { 40 + s * 18, 48 }, { 40 + s * 36, 46 } }, 1):clip(up:shrink(1)), WING.shade)
  c:fillMask(c:line({ { 40 + s * 18, 59 }, { 40 + s * 32, 60 } }, 1):clip(lo:shrink(1)), WING.shade)
  up:edge():each(function(x, y) if not up:has(x, y - 1) and c:get(x, y) == WING.base then c:put(x, y, WING.hi) end end)
end
-- poncho bleeding off the bottom
local cl = c:ellipse(40, 106, 34, 30):clip(c:rect(0, 70, 79, 99))
c:part(cl, CLOAK, { band = 3, pop = { x = 16, y = 86 } })
for y = 82, 99, 4 do for x = 12 + (y % 8), 68, 8 do if cl:has(x, y) and c:get(x, y) == CLOAK.base then c:put(x, y, CLOAK.shade) c:put(x, y + 1, CLOAK.shade) end end end
-- neck + scarf
c:part(c:rect(34, 64, 46, 72), BLUE, { band = 1, nopop = true })
c:part(c:rrect(23, 69, 57, 76, 3), PURP, { band = 2, pop = { x = 26, y = 70 } })
c:part(c:rrect(44, 76, 49, 90, 1), PURP, { band = 1, nopop = true })
for y = 79, 89, 3 do c:put(46, y, PURP.shade) end
-- head
local hd = c:ellipse(40, 54, 19, 13)
c:part(hd, BLUE, { band = 3, pop = { x = 26, y = 56 } })
-- compound eye domes with facets
for _, ex in ipairs{ 29.5, 50.5 } do
  local d = c:ellipse(ex, 48, 9, 8)
  c:part(d, EYEG, { band = 2, pop = { x = math.floor(ex) - 5, y = 43 } })
  d:each(function(x, y) if (x + 2 * y) % 4 == 0 and y % 2 == 0 and c:get(x, y) == EYEG.base then c:put(x, y, EYEG.shade) end end)
  d:each(function(x, y) if (x + 2 * y) % 4 == 2 and y % 2 == 1 and c:get(x, y) == EYEG.hi then c:put(x, y, EYEG.base) end end)
end
c:eyeLocked(27, 47) c:eyeLocked(48, 47)
-- snout: rounded clypeus plate with nostril dots + mandible smile
c:part(c:ellipse(40, 60.5, 5, 2.5), { hi = BLUE.hi, base = BLUE.hi, shade = BLUE.base, deep = BLUE.shade }, { band = 1, nopop = true })
c:put(38, 60, BLUE.shade) c:put(41, 60, BLUE.shade) c:put(37, 59, CREAM)
for _, q in ipairs{ { 35, 63 }, { 36, 64 }, { 37, 64 }, { 38, 65 }, { 39, 65 }, { 40, 65 }, { 41, 65 }, { 42, 64 }, { 43, 64 }, { 44, 63 } } do c:put(q[1], q[2], INK) end
c:put(39, 66, PURP.hi) c:put(40, 66, PURP.hi)
c:cheek(25, 59) c:cheek(53, 59)
-- straw hat
local hb = c:ellipse(40, 37, 25, 5)
c:part(hb, STRAW, { band = 2, nopop = true })
hb:each(function(x, y) if not hb:has(x, y + 1) then c:put(x, y, STRAW.deep) end end)
for x = 17, 62, 3 do if hb:has(x, 39) then c:put(x, 39, STRAW.shade) end end
local cr = c:rrect(28, 20, 52, 35, 5)
c:part(cr, STRAW, { band = 3, pop = { x = 31, y = 22 } })
for y = 23, 29, 3 do for x = 30 + (y % 2) * 2, 50, 4 do c:put(x, y, STRAW.shade) c:put(x + 1, y, STRAW.shade) end end
for x = 28, 52 do c:put(x, 30, PURP.hi) c:put(x, 31, x > 45 and PURP.shade or PURP.base) c:put(x, 32, PURP.base) c:put(x, 33, PURP.deep) end
c:stitch{ { 30, 31 }, { 50, 31 } }
-- quirk: moss growing on the brim with a little sprout
local ms = c:ellipse(22, 36, 6, 2.6)
ms:add(c:ellipse(27, 38, 3, 1.5)) ms:add(c:ellipse(17, 37, 2, 1.5))
c:part(ms, MOSS, { band = 1, pop = { x = 19, y = 34 } })
ms:each(function(x, y) if (x + y) % 3 == 0 and c:get(x, y) == MOSS.base then c:put(x, y, MOSS.shade) end end)
c:part(c:rect(21, 29, 21, 33), MOSS, { band = 0, nopop = true, inner = false })
c:part(oval(18.5, 28.5, 3, 1.5, -25), MOSS, { band = 1, nopop = true, inner = false })
c:part(oval(24, 28, 3, 1.5, 25), MOSS, { band = 1, nopop = true, inner = false })
c:finish{ outline = true }
backdrop(c, { base = "#8cba5a", shade = "#6a9a44", deep = "#4a7436" })
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
