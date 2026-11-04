-- npc-pebble-leafwhisker portrait (npc2 P1_28) species: field mouse
-- Honey-gold field mouse, huge round pink-lined ears, leaf-green smock with cream collar, whiskers,
-- pink nose. Prop in frame: wildflower crown (daisies on a vine); tail curls up lower-left.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-pebble-leafwhisker"
local FUR = { hi = "#ffd59a", base = "#eba557", shade = "#b8694a", deep = "#6e3a3e" }
local PINK = P.petal
local SMOCK = P.moss
local CREAM = { hi = P.cream, base = "#f3e2b8", shade = "#d4b98e", deep = "#9a7a5e" }
local AQUA = { base = "#a9dcd2", shade = "#7fbcbc", deep = "#55929e" }
local TOK = { r = { name = "crown" } }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end

-- tail curling up lower-left
c:part(c:line({ { 18, 92 }, { 12, 86 }, { 11, 78 }, { 14, 72 }, { 19, 72 }, { 20, 75 } }, 3), PINK, { band = 1 })
-- ears
local function ear(cx, cy)
  c:part(c:ellipse(cx, cy, 10, 10), FUR, { band = 2, pop = { cx - 6, cy - 5 } })
  c:part(c:ellipse(cx + 1, cy + 1, 6.5, 6.5), PINK, { band = 2, pop = { cx - 3, cy - 3 } })
end
ear(20, 25) ear(59, 25)
-- smock body + collar + pocket
c:part(c:ellipse(39.5, 96, 25, 24), SMOCK, { band = 2 })
c:part(c:rrect(46, 84, 56, 95, 2), SMOCK, { band = 1, sep = true, nopop = true })
c:stitch{ { 47, 85 }, { 55, 85 } }
c:part(c:ellipse(39.5, 70, 13, 3.5), CREAM, { band = 1 })
-- head with cheek fluff
local hd = c:ellipse(39.5, 51, 19.5, 16.5)
for _, q in ipairs{ { 20, 55 }, { 21, 59 }, { 59, 55 }, { 58, 59 } } do hd:add(c:ellipse(q[1], q[2], 1.5, 1.5)) end
c:part(hd, FUR, { band = 3, pop = { 27, 40 } })
for _, q in ipairs{ { 31, 41 }, { 45, 40 }, { 50, 44 }, { 26, 46 }, { 54, 50 }, { 36, 39 } } do keep(q[1], q[2], FUR.shade) keep(q[1], q[2] + 1, FUR.shade) end
-- muzzle, nose, mouth
c:part(c:ellipse(39.5, 61, 8.5, 5.5), CREAM, { band = 1, nopop = true })
for x = 37, 42 do keep(x, 56, PINK.base) keep(x, 57, PINK.base) end
for x = 38, 41 do keep(x, 58, PINK.shade) end
keep(39, 59, PINK.deep) keep(40, 59, PINK.deep) keep(37, 56, PINK.hi) keep(38, 56, PINK.hi) keep(42, 57, PINK.shade)
keep(39, 60, P.ink) keep(40, 60, P.ink)
for _, q in ipairs{ { 35, 61 }, { 36, 62 }, { 37, 62 }, { 38, 61 }, { 41, 61 }, { 42, 62 }, { 43, 62 }, { 44, 61 }, { 39, 61 }, { 40, 61 } } do keep(q[1], q[2], P.ink) end
keep(39, 62, PINK.base) keep(40, 62, PINK.base)
-- eyes + cheeks
c:eyeLocked(29, 48) c:eyeLocked(46, 48)
for _, x in ipairs{ 24, 53 } do for i = 0, 2 do keep(x + i, 57, PINK.base) keep(x + i, 58, PINK.base) end end
-- wildflower crown
c:line({ { 21, 44 }, { 25, 38 }, { 32, 35 }, { 40, 34 }, { 47, 35 }, { 54, 38 }, { 58, 44 } }, 2):each(function(x, y) c:put(x, y, SMOCK.shade, TOK) end)
c:line({ { 22, 43 }, { 26, 37 }, { 32, 34 }, { 40, 33 }, { 47, 34 }, { 53, 37 } }, 1):each(function(x, y) c:put(x, y, SMOCK.base, TOK) end)
local function daisy(x, y, col)
  for dy = -2, 2 do for dx = -2, 2 do
    local d = math.abs(dx) + math.abs(dy)
    if d >= 1 and d <= 2 and not (math.abs(dx) == 2 or math.abs(dy) == 2) or (d == 2 and (dx == 0 or dy == 0)) then
      c:put(x + dx, y + dy, (dx + dy > 0) and col.shade or col.base, TOK)
    end
  end end
  c:put(x - 1, y - 2, col.hi, TOK)
  c:put(x, y, P.gold.base, TOK) c:put(x - 1, y - 1 + 1, P.gold.hi, TOK)
end
daisy(24, 40, CREAM) daisy(31, 35, PINK) daisy(40, 33, P.sky) daisy(48, 35, CREAM) daisy(55, 40, P.dusk)
for _, q in ipairs{ { 28, 37 }, { 35, 34 }, { 44, 34 }, { 52, 37 } } do c:put(q[1], q[2], SMOCK.hi, TOK) c:put(q[1] + 1, q[2] - 1, SMOCK.base, TOK) end
c:finish{ outline = true }
for _, w in ipairs{ { { 30, 60 }, { 14, 57 } }, { { 30, 62 }, { 15, 65 } }, { { 49, 60 }, { 65, 57 } }, { { 49, 62 }, { 64, 65 } } } do
  c:fillMask(c:line(w, 1), FUR.deep)
end
backdrop(AQUA)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
