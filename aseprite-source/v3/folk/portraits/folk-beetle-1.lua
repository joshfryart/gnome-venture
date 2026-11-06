-- folk-beetle-1 portrait (folk F2_3) variant: 1
-- Generic rest-stop beetle villager. Upright chunky beetle: domed glossy elytra split at the tail, segmented
-- belly plates, stubby chitin limbs, lamellate club antennae, compound-eye domes around cream eyes, clypeus snout
-- + tiny mandibles. v1 gardener (straw hat with a nibbled brim, red neckerchief, trowel with soil),
-- v2 traveller (cap, striped scarf, pack + bedroll, lantern), v3 cook (dotted kerchief, apron, raised soup ladle).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local V = 1
local NAME = "folk-beetle-" .. V
local INK, GLINT, CREAM = "#2b1c26", "#fdf6dc", HP.P.cream
local VAR = {
  { shell = { hi = "#a8e07c", base = "#4fae5a", shade = "#2f7a62", deep = "#25495c" },
    chit  = { hi = "#7fa874", base = "#4e7a5c", shade = "#36564f", deep = "#2c3646" },
    belly = { hi = "#ece2a4", base = "#cfc278", shade = "#9a9064", deep = "#655c56" },
    cloth = { hi = "#ff9c84", base = "#e0584e", shade = "#a83a4e", deep = "#6a2846" },
    hat   = { hi = "#fbe596", base = "#e2b654", shade = "#b07c44", deep = "#6e4a3e" },
    metal = { hi = "#e6eef0", base = "#a8b8c4", shade = "#6c7890", deep = "#454a66" },
    wood  = { hi = "#e2a466", base = "#a8683a", shade = "#74443a", deep = "#4a2c34" },
    disc  = { base = "#bfe0a0", shade = "#90b888", deep = "#628a70" },
    hrx = 13, sr = 8.5 },
  { shell = { hi = "#f6bc7c", base = "#c8743c", shade = "#8e4642", deep = "#562a42" },
    chit  = { hi = "#a87868", base = "#74484c", shade = "#523444", deep = "#38243a" },
    belly = { hi = "#f2d6a8", base = "#d4a676", shade = "#9e7464", deep = "#644a52" },
    cloth = { hi = "#a0d6f4", base = "#4a92d2", shade = "#3a60a2", deep = "#2e3a70" },
    hat   = { hi = "#9ad8b8", base = "#4e9e8a", shade = "#386a70", deep = "#2a404e" },
    pack  = { hi = "#ecd8a4", base = "#bc9e6a", shade = "#846a54", deep = "#504242" },
    metal = { hi = "#ffe69a", base = "#d8a840", shade = "#9a6a3a", deep = "#5e4036" },
    glow  = { hi = "#fff4c0", base = "#ffd462", shade = "#eca044", deep = "#b0683a" },
    disc  = { base = "#a8d4f0", shade = "#7aa8d8", deep = "#5878b0" },
    hrx = 12, sr = 8 },
  { shell = { hi = "#cc94e2", base = "#8a54b8", shade = "#5c3c8e", deep = "#382a58" },
    chit  = { hi = "#8a7ab0", base = "#5a4c86", shade = "#403666", deep = "#2e2646" },
    belly = { hi = "#e6d8f0", base = "#c4b0d4", shade = "#9282a8", deep = "#5e5276" },
    cloth = { hi = "#fbf0d6", base = "#eadab6", shade = "#bfac9e", deep = "#857888" },
    hat   = { hi = "#ffa4ac", base = "#e2627a", shade = "#aa446a", deep = "#6c2e52" },
    metal = { hi = "#e8f0f2", base = "#aebccc", shade = "#707c96", deep = "#474c6a" },
    soup  = { hi = "#ffd08a", base = "#f09a4a", shade = "#c06440", deep = "#7a3c3c" },
    spot = "#e8c46a",
    disc  = { base = "#f4b8c4", shade = "#d88aa8", deep = "#a8648a" },
    hrx = 14, sr = 9.5 },
}
local R = VAR[V]

local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function part(m, r, band, pop) c:part(m, r, { band = band or 2, nopop = not pop, pop = pop }) return m end
local BOT = c:rect(0, 0, 79, 99)
local hx, hy = 39.5, 46
if V == 2 then
  part(c:rrect(52, 58, 73, 99, 4), R.pack, 2, { x = 55, y = 61 })
  part(c:rrect(52, 58, 73, 67, 3), R.pack, 1)
  part(c:rrect(50, 51, 75, 58, 3), R.hat, 1, { x = 52, y = 53 })
  for _, x in ipairs{ 57, 68 } do for y = 51, 58 do if c:get(x, y) then c:put(x, y, R.hat.deep) end end end
  part(c:rect(61, 65, 64, 69), R.metal, 1)
end
-- elytra shoulders
local sh = c:ellipse(25, 96, 17, 27) sh:add(c:ellipse(54, 96, 17, 27)) sh:clip(BOT)
part(sh, R.shell, 3, { x = 14, y = 80 })
c:line({ { 13, 77 }, { 11, 87 } }, 2):each(function(x, y) if sh:has(x, y) then c:put(x, y, R.shell.hi) end end)
c:line({ { 62, 74 }, { 65, 81 } }, 2):each(function(x, y) if sh:has(x, y) then c:put(x, y, R.shell.hi) end end)
c:put(14, 76, GLINT) c:put(61, 73, GLINT)
if V == 3 then
  for _, q in ipairs{ {14,84},{18,93},{63,83},{60,93},{10,95},{67,91} } do
    for dx = 0, 2 do for dy = 0, 1 do if sh:has(q[1] + dx, q[2] + dy) then c:put(q[1] + dx, q[2] + dy, R.spot) end end end
  end
end
local bel = c:rrect(26, 72, 53, 99, 8)
part(bel, R.belly, 2)
for _, yy in ipairs{ 80, 87, 94 } do for x = 26, 53 do if bel:has(x - 1, yy) and bel:has(x + 1, yy) then c:put(x, yy, R.belly.shade) end end end
part(c:ellipse(39.5, 67, 17, 4), R.shell, 1)
-- clothes
if V == 1 then
  part(c:poly{ { 22, 66 }, { 57, 66 }, { 39.5, 89 } }, R.cloth, 2, { x = 28, y = 68 })
  part(c:ellipse(39.5, 68, 3.5, 2.5), R.cloth, 1)
  for _, q in ipairs{ {30,72},{47,72},{36,78},{43,78},{39,84},{26,68},{52,68} } do c:put(q[1], q[2], R.cloth.hi) end
elseif V == 2 then
  part(c:line({ { 57, 68 }, { 40, 99 } }, 4), R.pack, 1)
  local sc = c:rrect(19, 62, 60, 72, 4)
  part(sc, R.cloth, 2, { x = 22, y = 64 })
  for x = 22, 58, 5 do for y = 62, 72 do if sc:has(x, y) and sc:has(x + 1, y) then c:put(x, y, R.cloth.shade) c:put(x + 1, y, R.cloth.shade) end end end
  local tl = c:line({ { 31, 70 }, { 30, 82 }, { 31, 92 } }, 6)
  part(tl, R.cloth, 2, { x = 29, y = 73 })
  for x = 28, 34, 2 do c:put(x, 95, R.cloth.deep) c:put(x, 96, R.cloth.deep) end
  for _, y in ipairs{ 78, 86 } do for x = 27, 35 do if tl:has(x, y) then c:put(x, y, R.cloth.shade) end end end
else
  part(c:line({ { 30, 75 }, { 27, 66 } }, 3), R.cloth, 1)
  part(c:line({ { 49, 75 }, { 52, 66 } }, 3), R.cloth, 1)
  part(c:rrect(28, 73, 51, 99, 4), R.cloth, 2, { x = 30, y = 75 })
  for x = 33, 46 do c:put(x, 86, R.cloth.shade) c:put(x, 93, R.cloth.shade) end
  for y = 86, 93 do c:put(33, y, R.cloth.shade) c:put(46, y, R.cloth.shade) end
  c:stitch{ { 31, 76 }, { 48, 76 } }
  part(c:ellipse(39.5, 89, 2, 1.5), R.hat, 1)
end
-- head
part(c:ellipse(hx, hy, 20, 17), R.chit, 3, { x = 27, y = 35 })
c:put(26, 34, GLINT)
for _, q in ipairs{ { 29.5, 44.5 }, { 50.5, 44.5 } } do part(c:ellipse(q[1], q[2], 4.5, 4.5), R.shell, 1) end
c:eyeLocked(27, 42) c:eyeLocked(48, 42)
part(c:rrect(35, 50, 44, 55, 2), R.shell, 2, { x = 36, y = 51 })
c:put(37, 51, R.shell.hi) c:put(38, 51, R.shell.hi)
for x = 36, 43 do c:put(x, 58, INK) end
c:put(35, 57, INK) c:put(44, 57, INK)
for x = 38, 41 do c:put(x, 59, "#c8506a") end
c:put(37, 59, INK) c:put(42, 59, INK) for x = 38, 41 do c:put(x, 60, INK) end
for _, q in ipairs{ {31,54},{31,55},{32,56},{33,57},{48,54},{48,55},{47,56},{46,57} } do c:put(q[1], q[2], R.chit.deep) end
c:cheek(23, 52) c:cheek(54, 52)
-- headwear
local ast
if V == 1 then
  local brim = c:ellipse(hx, 31, 27, 5.5)
  brim:cut(c:ellipse(66.5, 31.5, 2, 2))
  part(brim, R.hat, 2, { x = 16, y = 29 })
  local crown = c:rrect(27, 14, 52, 31, 7)
  part(crown, R.hat, 3, { x = 31, y = 17 })
  brim:each(function(x, y) if not crown:has(x, y) and (x * 2 + y) % 5 == 0 then c:put(x, y, R.hat.shade) end end)
  crown:each(function(x, y) if y < 24 and (x + y * 3) % 7 == 0 then c:put(x, y, R.hat.shade) end end)
  for x = 27, 52 do for y = 25, 27 do if crown:has(x, y) then c:put(x, y, y == 27 and R.cloth.shade or R.cloth.base) end end end
  ast = 15
elseif V == 2 then
  local cap = c:ellipse(hx, 34, 20, 12) cap:clip(c:rect(0, 0, 79, 35))
  part(cap, R.hat, 3, { x = 28, y = 25 })
  for y = 23, 34 do c:put(41, y, R.hat.shade) end
  c:line({ { 33, 24 }, { 27, 34 } }, 1):each(function(x, y) if cap:has(x, y) then c:put(x, y, R.hat.shade) end end)
  for x = 20, 59 do if cap:has(x, 34) then c:put(x, 34, R.hat.deep) end end
  part(c:ellipse(31, 36.5, 15, 3.5), R.hat, 2, { x = 20, y = 35 })
  part(c:ellipse(40.5, 22.5, 2.5, 1.5), R.cloth, 1)
  ast = 24
else
  local k = c:ellipse(hx, 40, 21, 14) k:clip(c:rect(0, 0, 79, 37))
  k:add(c:poly{ { 18, 34 }, { 25, 34 }, { 17, 42 } })
  part(k, R.hat, 3, { x = 28, y = 29 })
  k:each(function(x, y) if x % 5 == 0 and y % 4 == 0 then c:put(x, y, R.cloth.hi) end end)
  part(c:ellipse(14, 28, 4, 3), R.hat, 2)
  part(c:ellipse(11, 22, 3, 4), R.hat, 2, { x = 10, y = 20 })
  part(c:ellipse(18.5, 30.5, 2.5, 2.5), R.hat, 1)
  ast = 27
end
-- props
if V == 1 then
  part(c:line({ { 56, 80 }, { 62, 86 } }, 5), R.chit, 1)
  part(c:rect(61, 72, 64, 84), R.wood, 1)
  part(c:poly{ { 57, 72 }, { 68, 72 }, { 66, 63 }, { 62.5, 57 }, { 59, 63 } }, R.metal, 2, { x = 59, y = 63 })
  for y = 61, 70 do c:put(62, y, R.metal.shade) end
  for _, q in ipairs{ {62,58},{63,59},{61,60},{63,61} } do c:put(q[1], q[2], R.wood.shade) end
  part(c:ellipse(62.5, 85, 3.5, 3), R.chit, 1, { x = 61, y = 83 })
elseif V == 2 then
  part(c:line({ { 24, 80 }, { 17, 86 } }, 5), R.chit, 1)
  part(c:rrect(10, 89, 22, 91, 1), R.metal, 1)
  part(c:rrect(11, 92, 21, 99, 1), R.glow, 1, { x = 13, y = 93 })
  for y = 92, 99 do c:put(16, y, R.metal.shade) end
  part(c:ellipse(16.5, 86, 3.5, 3), R.chit, 1, { x = 15, y = 84 })
else
  part(c:line({ { 57, 84 }, { 64, 78 } }, 5), R.chit, 1)
  part(c:line({ { 65, 80 }, { 66, 62 }, { 68, 52 } }, 3), R.metal, 1)
  part(c:ellipse(68.5, 46, 6.5, 5), R.metal, 2, { x = 64, y = 43 })
  part(c:ellipse(68.5, 44.5, 4.5, 2.5), R.soup, 1, { x = 66, y = 43 })
  c:put(73, 52, R.soup.base) c:put(73, 53, R.soup.shade)
  part(c:ellipse(64.5, 79, 3.5, 3), R.chit, 1, { x = 63, y = 77 })
end
-- antenna clubs
for _, q in ipairs{ { 21, 7 }, { 58, 7 } } do
  part(c:ellipse(q[1], q[2], 3.5, 2.5), R.shell, 1, { x = q[1] - 2, y = q[2] - 1 })
  c:put(q[1] - 1, q[2], R.shell.deep) c:put(q[1], q[2], R.shell.deep) c:put(q[1] + 1, q[2], R.shell.deep)
end
c:finish{ outline = true }
local function stalk(pts) c:line(pts, 1):each(function(x, y) if not c:get(x, y) then c:put(x, y, INK) end end) end
stalk{ { 35, ast }, { 30, 11 }, { 23, 8 } }
stalk{ { 44, ast }, { 49, 11 }, { 56, 8 } }
local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and R.disc.base or R.disc.shade, "bg") end end)
local ring = disc:grow(1):cut(disc)
ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, R.disc.deep, "bg") end end)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
