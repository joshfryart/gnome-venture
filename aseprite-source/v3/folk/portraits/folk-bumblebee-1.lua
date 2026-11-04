-- folk-bumblebee-1 portrait (folk F2_2) variant: 1
-- gardener: straw hat, bib overall, trowel
local V = 1
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local GOLD = ({ { hi = "#ffe07a", base = "#f5b83a", shade = "#c97d3a", deep = "#8a4f4a" },
  { hi = "#fff09a", base = "#f2d24e", shade = "#c99e4a", deep = "#8a6a52" },
  { hi = "#ffc770", base = "#ee9836", shade = "#bf6438", deep = "#7f3f48" } })[V]
local FUR = ({ { hi = "#5c4a78", base = "#40325a", shade = "#30264a", deep = "#261d3c" },
  { hi = "#6a5070", base = "#4a3854", shade = "#372942", deep = "#2a2036" },
  { hi = "#6e4a62", base = "#4e3450", shade = "#38263f", deep = "#2a1c33" } })[V]
local MUZ = { hi = GOLD.hi, base = GOLD.hi, shade = GOLD.base, deep = GOLD.shade }
local WING = { hi = "#eef6f2", base = "#cfe4ee", shade = "#9fb6d8", deep = "#7480b4" }
local STRAW = { hi = "#fff0b0", base = "#e8c46a", shade = "#b88848", deep = "#7c5848" }
local LEAF = { hi = "#b6e07a", base = "#76b24e", shade = "#477e52", deep = "#2f5248" }
local STEEL = { hi = "#eef2f4", base = "#aebccb", shade = "#7484a4", deep = "#4c5276" }
local WOOD = { hi = "#e0a86a", base = "#b0703e", shade = "#7c4a3e", deep = "#52323e" }
local TEAL = { hi = "#9ae6d8", base = "#3fb4aa", shade = "#2a7a88", deep = "#294e68" }
local RUST = { hi = "#ffa878", base = "#de6440", shade = "#a3404a", deep = "#6c2c46" }
local LEATHER = { hi = "#d29a66", base = "#9c6440", shade = "#6c4440", deep = "#4a2e3c" }
local BRASS = { hi = "#ffe48c", base = "#e0aa3c", shade = "#a86c3c", deep = "#6c4048" }
local GLOW = { hi = "#fff4b8", base = "#ffd968", shade = "#f0a848", deep = "#c47040" }
local ROSE = { hi = "#ffc4c8", base = "#ee8a9c", shade = "#bc5a7e", deep = "#7e3a62" }
local CREAM = { hi = "#fff6dc", base = "#f4e6c4", shade = "#cdbca8", deep = "#958aa0" }
local HONEY = { hi = "#ffd870", base = "#e8862a", shade = "#b85a2c", deep = "#86443a" }
local BG = ({ { hi = "#c8e6a8", base = "#a6d08a", shade = "#7aae6e", deep = "#55845a" },
  { hi = "#c8b8ec", base = "#a898d4", shade = "#7c6cb0", deep = "#584c8a" },
  { hi = "#ffd49a", base = "#f4b46a", shade = "#d48852", deep = "#a8644a" } })[V]
local BLUSH = "#f39a8e"
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
local function under(c, m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], hex) end end
local function overlay(c, m, f, t) local l = {} m:each(function(x, y) local v = c:get(x, y)
  if v == f.hi or v == f.base then l[#l + 1] = { x, y, t.base } elseif v == f.shade then l[#l + 1] = { x, y, t.shade } elseif v == f.deep then l[#l + 1] = { x, y, t.deep } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], q[3]) end end
local function recol(c, m, map) local l = {} m:each(function(x, y) local v = map[c:get(x, y) or ""] if v then l[#l + 1] = { x, y, v } end end) for _, q in ipairs(l) do c:put(q[1], q[2], q[3]) end end
local function px(c, list, hex) for _, q in ipairs(list) do c:put(q[1], q[2], hex) end end
local function zig(y0, h, x0, x1) local m = HP.mask() for x = x0, x1 do local z = x % 2 for y = y0 + z, y0 + h - 1 do m:set(x, y) end end return m end
local NAME = "folk-bumblebee-" .. V
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- wings behind the shoulders
for _, s in ipairs{ -1, 1 } do
  local hind = oval(39.5 + s * 27, 79, 6, 4, s * -20)
  local fore = oval(39.5 + s * 24, 67, (V == 3) and 9 or 10, 5, s * -62)
  c:part(hind, WING, { band = 1, nopop = true }) c:part(fore, WING, { band = 2, nopop = true })
  c:fillMask(c:line({ { 39.5 + s * 20, 75 }, { 39.5 + s * 27, 60 } }, 1):clip(fore:shrink(1)), WING.shade)
  fore:edge():each(function(x, y) if not fore:has(x, y - 1) and c:get(x, y) == WING.base then c:put(x, y, WING.hi) end end)
end
if V == 2 then -- pack behind right shoulder, bedroll on top
  local pk = c:rrect(53, 58, 73, 92, 4) c:part(pk, LEATHER, { band = 3, pop = { x = 56, y = 64 } }) under(c, pk, LEATHER.deep)
  c:part(c:rrect(55, 63, 72, 72, 3), { hi = LEATHER.base, base = LEATHER.base, shade = LEATHER.shade, deep = LEATHER.deep }, { band = 1, nopop = true })
  c:part(c:rect(62, 71, 64, 74), BRASS, { band = 1, nopop = true })
  c:part(c:rrect(51, 53, 75, 60, 3), TEAL, { band = 2, pop = { x = 53, y = 54 } })
  for y = 54, 59 do c:put(70, y, TEAL.deep) end
end
-- fuzzy shoulders/body with stripes
local body = c:ellipse(39.5, 104, (V == 2) and 29 or 31, 32):clip(c:rect(0, 70, 79, 99))
for _, q in ipairs{ { 13, 86 }, { 16, 80 }, { 22, 76 }, { 57, 76 }, { 63, 80 }, { 66, 86 } } do body:add(HP.ellipse(q[1], q[2], 1.6, 1.6)) end
c:part(body, GOLD, { band = 3, pop = { x = 16, y = 84 } })
overlay(c, zig(84, 5, 0, 79):clip(body), GOLD, FUR) overlay(c, zig(95, 5, 0, 79):clip(body), GOLD, FUR)
for y = 76, 99, 3 do for x = 12 + (y % 2) * 2, 68, 4 do recol(c, c:rect(x, y, x, y + 1):clip(body), { [GOLD.base] = GOLD.shade, [FUR.base] = FUR.hi }) end end
if V == 1 then
  local bib = c:rrect(29, 81, 50, 99, 3) c:part(bib, LEAF, { band = 2, pop = { x = 30, y = 82 } })
  c:part(c:line({ { 31, 82 }, { 28, 73 } }, 3), LEAF, { band = 1, nopop = true })
  c:part(c:line({ { 48, 82 }, { 51, 73 } }, 3), LEAF, { band = 1, nopop = true })
  c:rect(34, 88, 45, 95):edge():each(function(x, y) c:put(x, y, LEAF.shade) end)
  c:stitch{ { 35, 90 }, { 44, 90 } }
  c:part(c:rect(30, 81, 32, 83), STRAW, { band = 1, nopop = true }) c:part(c:rect(47, 81, 49, 83), STRAW, { band = 1, nopop = true })
  local ruff = c:ellipse(39.5, 68, 14, 3.5)
  for _, x in ipairs{ 27, 32, 37, 42, 47, 52 } do ruff:add(HP.ellipse(x, 70.5, 2, 2)) end
  c:part(ruff, GOLD, { band = 1, pop = { x = 28, y = 67 } })
elseif V == 2 then
  c:part(c:line({ { 56, 73 }, { 33, 99 } }, 3):clip(body:copy()), LEATHER, { band = 1, nopop = true })
  c:part(c:rect(43, 85, 46, 88), BRASS, { band = 1, nopop = true })
else
  local sm = body:copy():clip(c:rect(0, 73, 79, 99)) c:part(sm, ROSE, { band = 3, pop = { x = 18, y = 80 } })
  for _, y in ipairs{ 82, 89, 96 } do c:part(c:ellipse(39.5, y, 1.5, 1.5), CREAM, { band = 1, nopop = true }) end
  for _, x in ipairs{ 26, 53 } do c:fillMask(c:line({ { x, 80 }, { x + (x < 40 and -1 or 1), 99 } }, 1):clip(sm), ROSE.shade) end
end
-- head
local hcx, hcy = 39.5, 46
local head = c:ellipse(hcx, hcy, 20, 18)
for _, a in ipairs{ 155, 170, 185, 200, 340, 355, 10, 25 } do
  local r = math.rad(a) head:add(HP.ellipse(hcx + math.cos(r) * 19.5, hcy + math.sin(r) * 17.5, 1.6, 1.6)) end
c:part(head, GOLD, { band = 3, pop = { x = 26, y = 42 } })
for _, q in ipairs{ { 30, 60 }, { 35, 62 }, { 44, 62 }, { 49, 60 }, { 23, 55 }, { 56, 55 } } do recol(c, c:rect(q[1], q[2], q[1], q[2] + 1), { [GOLD.base] = GOLD.shade }) end
local crown = head:copy():clip(c:rect(0, 0, 79, 36))
for x = 19, 60 do local d = ({ 1, 2, 0, 3, 1, 0, 2 })[(x * 3) % 7 + 1]
  for y = 37, 36 + d do if head:has(x, y + 1) then crown:set(x, y) end end end
c:part(crown, FUR, { band = 2, inner = false, pop = { x = 26, y = 31 } })
-- compound-eye patches + locked eyes
for _, ex in ipairs{ 32, 47 } do c:part(c:ellipse(ex, 47.5, 4.5, 5), FUR, { band = 1, nopop = true, inner = false }) end
c:eyeLocked(30, 45) c:eyeLocked(45, 45)
-- muzzle with button nose and small mandible ticks
local mz = c:ellipse(39.5, 56.5, 6.5, 3.5) c:part(mz, MUZ, { band = 1, nopop = true, inner = false })
px(c, { { 38, 53 }, { 39, 53 }, { 40, 53 }, { 41, 53 }, { 38, 54 }, { 39, 54 }, { 40, 54 }, { 41, 54 }, { 39, 55 }, { 40, 55 } }, FUR.base)
px(c, { { 38, 53 }, { 39, 53 } }, FUR.hi)
px(c, { { 36, 57 }, { 37, 58 }, { 38, 58 }, { 39, 58 }, { 40, 58 }, { 41, 58 }, { 42, 58 }, { 43, 57 } }, INK)
px(c, { { 38, 59 }, { 41, 59 } }, FUR.shade)
px(c, { { 25, 53 }, { 26, 53 }, { 27, 53 }, { 25, 54 }, { 26, 54 }, { 27, 54 }, { 52, 53 }, { 53, 53 }, { 54, 53 }, { 52, 54 }, { 53, 54 }, { 54, 54 } }, BLUSH)
-- props (front)
local function hand(x, y) c:part(c:ellipse(x, y, 3.5, 3), FUR, { band = 1, pop = { x = math.floor(x) - 2, y = math.floor(y) - 2 } }) end
if V == 1 then
  c:part(c:poly{ { 56, 79 }, { 65, 79 }, { 65, 72 }, { 61, 64 }, { 56, 72 } }, STEEL, { band = 2, pop = { x = 58, y = 72 } })
  c:fillMask(c:line({ { 60, 70 }, { 60, 77 } }, 1), STEEL.shade)
  c:part(c:rect(59, 80, 62, 82), STEEL, { band = 1, nopop = true })
  c:part(c:rrect(58, 83, 62, 94, 1), WOOD, { band = 1, pop = { x = 59, y = 84 } })
  hand(60, 88)
elseif V == 2 then
  local sc = c:rrect(19, 63, 60, 72, 4) c:part(sc, RUST, { band = 2, pop = { x = 21, y = 64 } }) under(c, sc, RUST.deep)
  for x = 22, 58, 3 do for y = 64, 71 do if c:get(x, y) == RUST.base then c:put(x, y, RUST.shade) end end end
  local tl = c:poly{ { 24, 70 }, { 33, 71 }, { 32, 90 }, { 23, 89 } } c:part(tl, RUST, { band = 2, pop = { x = 25, y = 72 } })
  for x = 23, 32, 2 do c:put(x, 90, RUST.shade) c:put(x, 91, RUST.deep) end
  for _, y in ipairs{ 76, 82 } do for x = 23, 33 do if tl:has(x, y) then c:put(x, y, BRASS.base) end end end
  c:fillMask(c:line({ { 18, 88 }, { 17, 87 }, { 17, 85 } }, 1), BRASS.deep)
  c:part(c:poly{ { 11, 92 }, { 23, 92 }, { 20, 89 }, { 14, 89 } }, BRASS, { band = 1, pop = { x = 15, y = 90 } })
  c:part(c:rect(12, 93, 22, 99), GLOW, { band = 2, nopop = true })
  for y = 93, 99 do c:put(17, y, BRASS.shade) c:put(12, y, BRASS.base) c:put(22, y, BRASS.shade) end
  px(c, { { 14, 94 }, { 14, 95 }, { 15, 94 } }, GLOW.hi)
  hand(19, 86)
else
  for _, s in ipairs{ -1, 1 } do c:part(c:ellipse(39.5 + s * 6, 72.5, 6.5, 3.5), CREAM, { band = 1, pop = { x = math.floor(39.5 + s * 6) - 3, y = 71 } }) end
  c:put(39, 73, CREAM.deep) c:put(40, 73, CREAM.deep)
  c:part(c:line({ { 60, 92 }, { 66, 68 } }, 2), STEEL, { band = 1, nopop = true })
  local bowl = c:ellipse(67.5, 64.5, 5, 3.5) c:part(bowl, STEEL, { band = 2, pop = { x = 64, y = 65 } }) under(c, bowl, STEEL.deep)
  c:part(c:ellipse(67.5, 63, 3.5, 1.4), HONEY, { band = 1, pop = { x = 66, y = 62 } })
  px(c, { { 72, 65 }, { 72, 66 }, { 72, 67 }, { 72, 68 }, { 71, 69 }, { 72, 69 }, { 73, 69 } }, HONEY.base) c:put(72, 69, HONEY.hi)
  hand(60, 88)
end
-- headwear + antenna tips
local ants
if V == 1 then
  local brim = c:ellipse(39.5, 30, 27, 5)
  c:part(brim, STRAW, { band = 2, pop = { x = 16, y = 28 } }) under(c, brim, STRAW.deep)
  local cr = c:rrect(28, 14, 51, 29, 6) c:part(cr, STRAW, { band = 3, pop = { x = 31, y = 17 } })
  c:part(c:rect(28, 24, 51, 27):clip(cr), LEAF, { band = 1, nopop = true })
  brim:copy():add(cr):each(function(x, y) if c:get(x, y) == STRAW.base and (x + 2 * y) % 5 == 0 then c:put(x, y, STRAW.shade) end end)
  ants = { { { 31, 15 }, { 27, 10 }, { 23, 6 } }, { { 48, 15 }, { 52, 10 }, { 56, 6 } } }
elseif V == 2 then
  local cap = c:ellipse(39.5, 34, 21, 13):clip(c:rect(0, 0, 79, 35)) c:part(cap, TEAL, { band = 3, pop = { x = 27, y = 25 } })
  local rim = c:rrect(18, 32, 61, 38, 3) c:part(rim, TEAL, { band = 2, nopop = true }) under(c, rim, TEAL.deep)
  for x = 19, 60, 2 do for y = 33, 36 do if c:get(x, y) == TEAL.base then c:put(x, y, TEAL.shade) end end end
  c:part(c:ellipse(43, 19.5, 4.5, 4.5), RUST, { band = 2, pop = { x = 41, y = 17 } })
  ants = { { { 25, 27 }, { 20, 21 }, { 15, 14 } }, { { 54, 27 }, { 59, 21 }, { 64, 14 } } }
else
  local kf = c:ellipse(39.5, 37, 22, 14):clip(c:rect(0, 0, 79, 39)) c:part(kf, CREAM, { band = 3, pop = { x = 26, y = 27 } })
  for y = 26, 37, 5 do for x = 21 + (y % 2) * 3, 58, 6 do
    if kf:has(x, y) and kf:has(x + 1, y + 1) then px(c, { { x, y }, { x + 1, y }, { x, y + 1 }, { x + 1, y + 1 } }, ROSE.base) end end end
  for x = 17, 62 do if kf:has(x, 39) then c:put(x, 39, CREAM.shade) end end
  local kn = c:ellipse(58, 27, 3, 2.5) kn:add(c:poly{ { 60, 26 }, { 69, 20 }, { 71, 24 }, { 61, 28 } }) kn:add(c:poly{ { 60, 28 }, { 69, 31 }, { 67, 35 }, { 59, 30 } })
  c:part(kn, CREAM, { band = 1, nopop = true }) px(c, { { 66, 22 }, { 67, 22 }, { 65, 32 }, { 66, 32 } }, ROSE.base)
  c:part(c:poly{ { 36, 39 }, { 42, 39 }, { 44, 43 }, { 40, 41 }, { 37, 43 } }, GOLD, { band = 1, nopop = true, inner = false })
  ants = { { { 31, 25 }, { 28, 17 }, { 26, 10 } }, { { 48, 25 }, { 51, 17 }, { 53, 10 } } }
end
for _, a in ipairs(ants) do local t = a[3] c:part(c:ellipse(t[1] + .5, t[2] - 1, 2.2, 2.2), FUR, { band = 1, pop = { x = t[1] - 1, y = t[2] - 3 } }) end
c:finish{ outline = true }
for _, a in ipairs(ants) do c:fillMask(c:line({ a[1], a[2], { a[3][1], a[3][2] + 1 } }, 1), INK) end
backdrop(BG)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
