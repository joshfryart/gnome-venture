-- village-honeybrook PASS B (final). Village card scene 160x100 (welcome step 2), full canvas, no outer outline.
-- Planes: sky (3 bands, sun, puffs) + far hills (2 low-contrast tones, orchard bumps);
-- mid: a brook winding from the far left down to the front right, an arched footbridge, a thatched
-- hero cottage with a skep bench, a small far cottage, apple trees; near: a light grassy bank with
-- reeds, clover and meadow flowers.
-- quirk: a gnome sneaks a pot of honey over the footbridge, three bees from the skeps on his trail.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = app.params.name or "village-honeybrook"
local c = HP.canvas{ w = 160, h = 100, scale = 1, name = NAME }
local sin, floor, abs, min, max = math.sin, math.floor, math.abs, math.min, math.max
local seed = 5
local function rnd() seed = (seed * 1103515245 + 12345) % 2147483648 return seed / 2147483648 end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local FAR1, FAR2 = "#a9dccb", "#93cfb4"
local CREAMR = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local GRASS_HI = "#b4dc72"
local function sprite(rows, x0, y0, map, edge)
  local m = HP.mask()
  for j, row in ipairs(rows) do for i = 1, #row do if row:sub(i, i) ~= "." then m:set(x0 + i - 1, y0 + j - 1) end end end
  c:rim(m, edge or P.ink)
  c:paint(rows, x0, y0, map)
  return m
end

------------------------------------------------------------ SKY
c:stripes(0, 50, { P.sky.shade, P.sky.base, P.sky.hi }, { 3, 4, 4 })
c:fillMask(E(17, 11, 6, 6), P.gold.base) c:fillMask(E(16, 10, 4, 4), P.gold.hi)
c:cloud(40, 18, 24, P.cream, P.sky.hi)
c:cloud(118, 22, 26, P.cream, P.sky.hi)
c:cloud(86, 30, 12, P.cream, P.sky.hi)
for _, g in ipairs{ {136, 7}, {142, 10}, {131, 10} } do c:px(g[1], g[2], P.sky.deep) c:px(g[1] - 1, g[2] - 1, P.sky.deep) c:px(g[1] + 1, g[2] - 1, P.sky.deep) end

------------------------------------------------------------ FAR (2 tones, orchard bumps)
c:terrain(function(x) return 40 + 5 * sin(x / 22 + 2.4) + 2 * sin(x / 8) end, FAR1)
local far2 = function(x)
  local y = 46 + 3 * sin(x / 16 + 1)
  for t = 6, 158, 9 do local dx = abs(x - t) if dx < 4 and (t % 4 ~= 0) then y = min(y, 44 + 3 * sin(t / 16 + 1) + dx * dx * .35 - 3) end end
  return y
end
c:terrain(far2, FAR2)
c:terrain(function(x) return 50 + 1.5 * sin(x / 14 + 2) end, P.moss.hi)
c:terrain(function(x) return 56 + 2 * sin(x / 19) end, P.moss.base)
for i = 1, 60 do local x, y = floor(rnd() * 160), 58 + floor(rnd() * 30) c:px(x, y, P.moss.shade) c:px(x + 1, y - 1, P.moss.shade) end

------------------------------------------------------------ BROOK (far left, winding to the front right)
local pts = { {6, 52}, {22, 56}, {40, 60}, {56, 66}, {72, 72}, {90, 78}, {106, 86}, {118, 94}, {124, 104} }
local water = HP.mask()
for i = 1, #pts - 1 do
  local a, b = pts[i], pts[i + 1]
  for s = 0, 10 do
    local t = s / 10
    local x, y = a[1] + (b[1] - a[1]) * t, a[2] + (b[2] - a[2]) * t
    local hw = 1 + (y - 52) * .27
    water:add(E(x, y, hw * 1.5, max(.5, hw * .55)))
  end
end
water:clip(c:rect(0, 51, 159, 99))
c:rim(water, P.moss.deep)
c:fillMask(water, P.sea.base)
water:each(function(x, y) if not water:has(x, y - 2) then c:px(x, y, P.sea.shade) end end)            -- far-bank reflection
water:each(function(x, y) if not water:has(x, y + 1) then c:px(x, y, P.sea.hi) end end)               -- near-bank lip
for i = 1, 45 do
  local x, y = floor(rnd() * 150), 60 + floor(rnd() * 40)
  if water:has(x - 1, y) and water:has(x + 3, y) and water:has(x, y - 2) and water:has(x, y + 2) then
    R(x, y, x + 1 + (i % 2), y, P.sea.hi) if y > 78 then c:px(x - 1, y + 1, P.sea.shade) c:px(x + 2 + (i % 2), y + 1, P.sea.shade) end
  end
end
-- bank pebbles
for _, p in ipairs{ {48, 68}, {86, 82}, {100, 90}, {66, 66}, {112, 85} } do c:fillMask(E(p[1], p[2], 1.5, .5), P.stone.base) c:px(p[1] - 1, p[2], P.stone.hi) end

------------------------------------------------------------ SMALL FAR COTTAGE (left, far bank)
local function cottage(x, y, w, hh, rh, o)
  local wall = c:rect(x, y - hh, x + w, y)
  local roof = c:poly{ {x - 3, y - hh + 1}, {x + 2, y - hh - rh + 3}, {x + w / 2, y - hh - rh}, {x + w - 2, y - hh - rh + 3}, {x + w + 3, y - hh + 1} }
  roof:add(c:rrect(x - 3, y - hh - 2, x + w + 3, y - hh + 2, 2))
  local chim = o.chim and c:rect(o.chim, y - hh - rh - 1, o.chim + 3, y - hh - rh + 6) or HP.mask()
  c:rim(wall:copy():add(roof):add(chim), o.edge or P.ink)
  c:part(wall, CREAMR, { band = 2, nopop = true })
  -- timber frame
  for _, bx in ipairs{ x, x + w } do R(bx, y - hh, bx, y, P.wood.shade) end
  R(x, y - hh + 1, x + w, y - hh + 1, P.wood.shade)
  if o.chim then c:part(chim:cut(roof), "stone", { band = 1, nopop = true }) R(o.chim - 1, y - hh - rh - 1, o.chim + 4, y - hh - rh - 1, P.stone.shade) end
  -- thatch: gold, rows of scallops, rolled eave
  c:part(roof, "gold", { band = 2, pop = { x = x + 2, y = y - hh - rh + 5 } })
  for yy = y - hh - rh + 4, y - hh - 1, 3 do
    for xx = x - 2, x + w + 2 do if roof:has(xx, yy) and (xx + yy) % 4 ~= 0 then c:px(xx, yy, P.gold.shade) end end
  end
  R(x - 3, y - hh + 2, x + w + 3, y - hh + 2, P.gold.deep)
  roof:each(function(xx, yy) if not roof:has(xx, yy - 1) and yy < y - hh - 2 then c:px(xx, yy, P.gold.shade) c:px(xx, yy + 1, P.gold.hi) end end)
  for xx = x, x + w, 4 do if roof:has(xx, y - hh - rh + 1) then c:px(xx, y - hh - rh, P.gold.deep) end end
  for xx = x - 2, x + w + 2, 3 do c:px(xx, y - hh + 1, P.gold.hi) end
  return wall, roof
end
cottage(34, 55, 16, 8, 9, { chim = 44, edge = P.wood.deep })
R(39, 50, 41, 52, P.gold.hi) c:px(40, 50, P.wood.shade)          -- lit window
R(45, 50, 47, 55, P.moss.shade)                                    -- door

------------------------------------------------------------ APPLE TREES
local function atree(x, y, r, edge)
  c:fillMask(E(x, y + 1, r, 1.5), P.moss.shade)
  local tr = c:poly{ {x - 3, y + 1}, {x + 3, y + 1}, {x + 1, y - 4}, {x + 1, y - r}, {x - 1, y - r}, {x - 1, y - 4} }
  local cr = E(x, y - r - 6, r, r * .8):add(E(x - r * .6, y - r - 2, r * .55, r * .45)):add(E(x + r * .6, y - r - 2, r * .55, r * .45))
    :add(E(x - r * .45, y - r * 1.55 - 4, r * .5, r * .4)):add(E(x + r * .5, y - r * 1.45 - 4, r * .5, r * .45))
  c:rim(tr:copy():add(cr), edge)
  c:part(tr, "wood", { band = 1, nopop = true })
  c:part(cr, "moss", { band = 3, pop = { x = x - r * .5, y = y - r * 1.6 - 2 } })
  for i = 1, floor(r * 2.2) do
    local lx, ly = x - r + floor(rnd() * r * 2), floor(y - r * 1.9 + rnd() * r * 1.4)
    if cr:has(lx, ly) and cr:has(lx + 1, ly + 1) then c:px(lx, ly, P.moss.shade) c:px(lx + 1, ly + 1, P.moss.shade) end
  end
  for i = 1, floor(r * 1.6) do
    local ax, ay = x - r + 2 + floor(rnd() * (r * 2 - 4)), floor(y - r * 1.8 + rnd() * r * 1.3)
    if cr:has(ax - 1, ay - 1) and cr:has(ax + 2, ay + 2) then R(ax, ay, ax + 1, ay + 1, P.ember.base) c:px(ax, ay, P.ember.hi) c:px(ax + 1, ay + 1, P.ember.shade) end
  end
  return cr
end
atree(150, 66, 11, P.moss.deep)

------------------------------------------------------------ HERO COTTAGE (right)
local wall, roof = cottage(100, 70, 36, 18, 18, { chim = 126 })
-- door (rounded top, green) + step
local door = c:rrect(106, 58, 113, 70, 3)
c:rim(door, P.ink, c:rect(0, 0, 159, 69))
c:part(door, "moss", { band = 1, nopop = true, inner = false })
R(109, 58, 109, 70, P.moss.shade) c:px(112, 64, P.gold.hi)
R(104, 71, 115, 71, P.stone.base) R(105, 72, 114, 72, P.stone.shade)
-- windows with sea shutters + flower box
for _, wx in ipairs{ 119, 129 } do
  local wn = c:rect(wx, 57, wx + 4, 61)
  c:rim(wn, P.wood.deep) c:fillMask(wn, P.gold.hi)
  R(wx + 2, 57, wx + 2, 61, P.wood.base) R(wx, 59, wx + 4, 59, P.wood.base) c:px(wx, 57, P.cream)
  R(wx - 2, 57, wx - 2, 61, P.sea.shade) R(wx + 6, 57, wx + 6, 61, P.sea.shade)
  R(wx - 1, 63, wx + 5, 64, P.wood.base) R(wx - 1, 64, wx + 5, 64, P.wood.shade)
  for k = 0, 3 do c:px(wx - 1 + k * 2, 62, (k % 2 == 0) and P.petal.base or P.gold.base) end
end
-- a honey-gold round window in the thatch
c:rim(E(118, 43, 2, 2), P.gold.deep) c:fillMask(E(118, 43, 2, 2), P.gold.hi) c:px(117, 42, P.cream)

------------------------------------------------------------ SKEP BENCH (right of the cottage)
local function skep(x, y)
  local m = E(x, y - 4, 4, 5):clip(c:rect(0, 0, 159, y)):add(c:rect(x - 4, y - 2, x + 4, y))
  m:add(c:rect(x, y - 10, x, y - 10))
  c:rim(m, P.ink)
  c:part(m, "gold", { band = 2, pop = { x = x - 3, y = y - 8 } })
  for yy = y - 7, y, 2 do c:fillMask(c:rect(x - 4, yy, x + 4, yy):clip(m), P.gold.shade) end
  m:each(function(xx, yy) if not m:has(xx + 2, yy) and yy % 2 == 1 then c:px(xx, yy, P.gold.deep) end end)
  c:fillMask(E(x, y - 1, 1.5, 1.5):clip(c:rect(0, 0, 159, y)), P.ink)
  c:px(x - 1, y - 8, P.gold.hi)
end
R(137, 75, 159, 76, P.wood.base) R(137, 76, 159, 76, P.wood.shade) R(139, 77, 139, 80, P.wood.deep) R(156, 77, 156, 80, P.wood.deep)
c:rim(c:rect(137, 75, 159, 76), P.ink, c:rect(136, 74, 159, 77))
skep(143, 74) skep(153, 74)
-- path: bridge to the cottage door
local lane = c:poly{ {88, 67}, {96, 67}, {108, 70}, {112, 74}, {100, 75}, {90, 71} }:cut(water)
c:fillMask(lane, P.gold.hi) lane:each(function(x, y) if not lane:has(x, y + 1) then c:px(x, y, "#e7b873") end end)
for _, s in ipairs{ {94, 70}, {101, 72}, {107, 73} } do c:px(s[1], s[2], "#e7b873") c:px(s[1] + 1, s[2], "#e7b873") end

------------------------------------------------------------ FOOTBRIDGE (arched, over the brook)
local bx0, bx1, by = 58, 90, 74
local arch = HP.mask()
for x = bx0, bx1 do
  local u = (x - (bx0 + bx1) / 2) / ((bx1 - bx0) / 2)
  local h = floor(6 - 6 * u * u + .5)
  for y = by - 2 - h, by - h + 1 do arch:set(x, y) end
end
local posts, rail = HP.mask(), HP.mask()
for _, x in ipairs{ bx0 + 2, bx0 + 9, (bx0 + bx1) // 2, bx1 - 9, bx1 - 2 } do
  local u = (x - (bx0 + bx1) / 2) / ((bx1 - bx0) / 2)
  local top = by - 2 - floor(6 - 6 * u * u + .5)
  posts:add(c:rect(x, top - 6, x, top - 1))
end
for x = bx0 + 2, bx1 - 2 do
  local u = (x - (bx0 + bx1) / 2) / ((bx1 - bx0) / 2)
  rail:set(x, by - 2 - floor(6 - 6 * u * u + .5) - 6)
end
c:rim(arch:copy():add(posts):add(rail), P.ink)
c:part(arch, "wood", { band = 1, nopop = true, inner = false })
for x = bx0 + 1, bx1 - 1, 3 do for y = by - 10, by do if arch:has(x, y) and not arch:has(x, y - 1) then c:px(x, y + 1, P.wood.shade) end end end
arch:each(function(x, y) if not arch:has(x, y + 1) then c:px(x, y, P.wood.deep) end end)
c:fillMask(posts, P.wood.shade) c:fillMask(rail, P.wood.base)
-- bridge reflection in the water
arch:each(function(x, y) local ry = 2 * by - y + 1 if water:has(x, ry) and (x + ry) % 2 == 0 then c:px(x, ry, P.sea.shade) end end)

------------------------------------------------------------ QUIRK: honey thief + three bees
c:paint({
  "....kk...",
  "...kRk...",
  "..kRRk...",
  "..kRrRk..",
  ".kRRRrk..",
  "kkSSSkk..",
  ".kiSSk...",
  "kGkCnCk..",
  "kGGkCCCk.",
  "kgGkCCck.",
  ".kkBBBBk.",
  "..kBBbBk.",
  "..kWk.kWk",
}, 70, 51, { k = "ink", R = "ember.base", r = "ember.shade", S = "skinA.base", n = "skinA.shade", i = "ink", C = "cream", c = "stone.hi", G = "gold.base", g = "gold.shade", B = "moss.shade", b = "moss.deep", W = "wood.shade" })
c:px(70, 57, P.gold.hi)
-- bees and their dotted flight path from the skeps
local function bee(x, y)
  sprite({ ".ww.", "GkGk", "GkGk" }, x, y - 1, { w = "cream", G = "gold.base", k = "ink" }, P.wood.deep)
  c:px(x, y, P.gold.hi)
end
bee(84, 49) bee(93, 44) bee(102, 48)
for _, p in ipairs{ {108, 46}, {111, 44}, {114, 42}, {89, 47}, {98, 45}, {80, 51} } do c:px(p[1], p[2], P.cream) end

------------------------------------------------------------ NEAR: light grassy bank, apple tree, reeds, flowers
local bankL = c:terrain(function(x) return 86 + 2 * sin(x / 11) + max(0, (x - 70)) * .4 end, nil, 99, 0, 104):cut(water)
local bankR = c:terrain(function(x) return 90 + 2 * sin(x / 9) end, nil, 99, 128, 159):cut(water)
local bank = bankL:copy():add(bankR)
c:fillMask(bank, P.moss.base)
bank:each(function(x, y) if not bank:has(x, y - 1) then c:px(x, y, GRASS_HI) c:px(x, y - 1, P.moss.shade) end end)
for i = 1, 70 do
  local x, y = floor(rnd() * 160), 86 + floor(rnd() * 14)
  if bank:has(x, y) and bank:has(x, y - 2) then c:px(x, y, P.moss.shade) c:px(x, y - 1, GRASS_HI) end
end
-- low wattle fence on the left bank
do
  local f = HP.mask()
  for _, x in ipairs{ 38, 45, 52 } do f:add(c:rect(x, 75, x, 81)) end
  f:add(c:rect(38, 77, 52, 77)):add(c:rect(38, 79, 52, 79))
  c:rim(f, P.wood.deep) c:fillMask(f, P.wood.base)
  for _, x in ipairs{ 38, 45, 52 } do c:px(x, 75, P.wood.hi) end R(39, 79, 52, 79, P.wood.shade)
end
for i = 1, 30 do
  local x, y = 26 + floor(rnd() * 70), 76 + floor(rnd() * 10)
  if not water:has(x, y) and not water:has(x, y + 1) and not water:has(x + 1, y) then
    local col = ({ P.petal.base, P.gold.hi, P.dusk.hi, P.cream })[1 + i % 4]
    c:px(x, y, col) c:px(x, y + 1, P.moss.shade)
  end
end
local tree = atree(20, 84, 14, P.ink)
sprite({
  "..rRr.....",
  ".rRRrRr...",
  "WWWWWWWW..",
  "wWwWwWwW..",
  ".wWwWwW...",
}, 28, 81, { r = "ember.shade", R = "ember.base", W = "wood.base", w = "wood.shade" })
c:px(29, 81, P.ember.hi) c:px(32, 82, P.ember.hi)
sprite({ "RR", "Rr" }, 8, 85, { R = "ember.base", r = "ember.shade" })
-- reeds / cattails on the banks
for _, r in ipairs{ {94, 90, 11}, {97, 92, 8}, {136, 94, 10}, {139, 95, 13}, {142, 96, 9} } do
  local st = c:rect(r[1], r[2] - r[3], r[1], r[2])
  local head = c:rect(r[1], r[2] - r[3] - 3, r[1] + 1, r[2] - r[3])
  c:rim(st:copy():add(head), P.moss.deep)
  c:fillMask(st, P.moss.shade) c:fillMask(head, P.wood.shade) c:px(r[1], r[2] - r[3] - 3, P.wood.base) c:px(r[1], r[2] - r[3] - 4, P.moss.shade)
  c:px(r[1] - 1, r[2] - 4, P.moss.base) c:px(r[1] - 2, r[2] - 6, P.moss.base) c:px(r[1] + 1, r[2] - 2, P.moss.base)
end
-- flowers on the bank
local cols = { "petal", "gold", "dusk" }
for i = 1, 22 do
  local x, y = floor(rnd() * 156) + 2, 88 + floor(rnd() * 10)
  if bank:has(x, y) and bank:has(x, y + 2) and not tree:has(x, y) then
    local col = (i % 4 == 0) and { hi = P.cream, base = P.cream, shade = P.stone.hi } or P[cols[1 + i % 3]]
    c:px(x, y + 1, P.moss.shade) c:px(x, y, col.hi) c:px(x - 1, y, col.base) c:px(x + 1, y, col.shade) c:px(x, y - 1, col.base)
  end
end
-- lavender clump, bottom right (the bees' favourite)
do
  local bush = HP.mask()
  for i = 0, 6 do
    local x, top = 145 + i * 2, 84 + ((i * 3) % 4)
    bush:add(c:rect(x, top, x, 99))
  end
  local leaves = E(151, 98, 9, 4)
  c:rim(bush:copy():add(leaves), P.ink)
  c:fillMask(leaves, P.moss.shade) c:fillMask(c:rect(144, 95, 158, 95):clip(leaves), P.moss.base)
  for i = 0, 6 do
    local x, top = 145 + i * 2, 84 + ((i * 3) % 4)
    for y = top, top + 6 do c:px(x, y, (y - top) % 2 == 0 and P.dusk.base or P.dusk.shade) end
    c:px(x, top, P.dusk.hi) c:px(x, top + 7, P.moss.shade) c:px(x, top + 8, P.moss.shade)
  end
end
-- clover patch
for _, p in ipairs{ {44, 95}, {60, 97}, {146, 96} } do
  c:px(p[1], p[2], P.moss.hi) c:px(p[1] + 2, p[2], P.moss.hi) c:px(p[1] + 1, p[2] - 1, P.moss.hi) c:px(p[1] + 1, p[2] + 1, P.moss.deep)
end

-- a duck and duckling paddling down the brook
c:paint({
  ".kk.....",
  "kCik....",
  "kCCkoo..",
  ".kCCk...",
  "kCCCCCk.",
  "kCCCcCCk",
  ".kkkkkk.",
}, 103, 80, { k = "ink", C = "cream", c = "stone.hi", i = "ink", o = "gold.base" })
c:px(102, 86, P.sea.hi) c:px(111, 86, P.sea.hi) c:px(112, 86, P.sea.hi)
c:paint({ ".kk.", "kGGo", "kGGk", ".kk." }, 115, 87, { k = "ink", G = "gold.hi", o = "gold.base" })
-- near daisies (ink edged)
for _, f in ipairs{ {6, 94}, {38, 92}, {72, 96}, {86, 92}, {146, 94}, {156, 98}, {52, 98} } do
  local x, y = f[1], f[2]
  R(x, y + 2, x, y + 6, P.moss.shade) c:px(x + 1, y + 4, P.moss.base)
  local pm = HP.mask() pm:set(x, y - 2) pm:set(x, y + 2) pm:set(x - 2, y) pm:set(x + 2, y) pm:add(c:rect(x - 1, y - 1, x + 1, y + 1))
  c:rim(pm, P.ink) c:fillMask(pm, P.cream) c:px(x + 1, y + 1, P.stone.hi) c:px(x, y + 2, P.stone.hi)
  c:px(x, y, P.gold.base) c:px(x - 1, y, P.gold.hi)
end

HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
