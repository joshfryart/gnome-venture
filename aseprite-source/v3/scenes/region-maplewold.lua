-- region-maplewold 300x200 (x6 = 1800x1200). Jigsaw: one feature per 50x50 cell (6x4).
-- quirk: bear in a tiny scarf fishing under the footbridge (cell 2,1).
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = dofile(d .. "/../lib/palette.lua")
local out = app.params.out or "./"
local c = HP.canvas{ w = 300, h = 200, scale = 6, name = "region-maplewold" }
local function rim(m, hex) c:fillMask(m:grow(1):cut(m), hex) end
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local E = function(cx, cy, rx, ry, hex) c:fillMask(c:ellipse(cx, cy, rx, ry), hex) end
local PUMP = { hi = P.gold.base, base = P.ember.hi, shade = P.ember.base, deep = P.ember.shade }
local BIRCH = { hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade }

-- FAR plane: sky bands, sun, puffs, two mountain layers (no ink)
c:bands(0, 44, "sky", 4)
E(22, 12, 8, 8, P.gold.hi) E(22, 12, 5, 5, P.gold.base)
local function cloud(x, y)
  E(x, y, 4, 3, P.cream) E(x + 6, y - 1, 5, 4, P.cream) E(x + 13, y, 4, 3, P.cream) R(x - 4, y + 1, x + 17, y + 3, P.cream)
end
cloud(160, 8) cloud(245, 14) cloud(95, 6)
local function peak(x0, x1, top, cx, hex, snow)
  c:fillMask(c:poly{ {x0, 48}, {cx, top}, {x1, 48} }, hex)
  if snow then c:fillMask(c:poly{ {cx, top}, {cx - 6, top + 7}, {cx - 2, top + 5}, {cx, top + 8}, {cx + 3, top + 5}, {cx + 6, top + 7} }, P.stone.hi) end
end
peak(50, 110, 12, 72, P.dusk.base, true) peak(190, 260, 18, 222, P.dusk.base, true)
peak(20, 80, 28, 45, P.dusk.shade) peak(150, 215, 26, 183, P.dusk.shade) peak(235, 310, 24, 280, P.dusk.shade)

-- ground: irregular colour patches (nearest jittered centre), hue varies between neighbours
local cols = { P.moss.base, P.gold.shade, P.moss.shade }
local cen = {}
for r = 0, 3 do for q = 0, 5 do
  local jx, jy = ((q * 7 + r * 13) % 11) - 5, ((q * 11 + r * 5) % 9) - 4
  cen[#cen + 1] = { q * 50 + 25 + jx, r * 50 + 25 + jy, cols[(q + r * 2) % 3 + 1] }
end end
for y = 0, 199 do
  for x = 0, 299 do
    local top = 42 + math.floor(3 * math.sin(x / 9) + 0.5)
    if y >= top then
      local best, bd = nil, 1e9
      for _, p in ipairs(cen) do local dd = (p[1] - x) ^ 2 + (p[2] - y) ^ 2 if dd < bd then bd, best = dd, p[3] end end
      c:px(x, y, best)
    end
  end
end
-- dark rolling-hill rim under mountains
for x = 0, 299 do local top = 42 + math.floor(3 * math.sin(x / 9) + 0.5) c:px(x, top, P.moss.deep) end

-- helpers
local function tree(x, y, ramp, s)  -- maple: trunk + 3-blob canopy
  s = s or 1
  c:part(c:rect(x - 1, y, x + 1, y + 7 * s), "wood", { band = 1, nopop = true })
  local m = c:ellipse(x, y - 3 * s, 7 * s, 6 * s):add(c:ellipse(x - 5 * s, y, 5 * s, 4 * s)):add(c:ellipse(x + 5 * s, y, 5 * s, 4 * s))
  rim(m, P[ramp].deep) c:part(m, ramp)
end
local function pumpkin(x, y, r)
  local m = c:ellipse(x, y, r + 1, r) rim(m, P.ember.shade) c:part(m, PUMP, { band = 1 }) R(x, y - r - 2, x, y - r, P.moss.shade)
end
local function stone(x, y, rx, ry) local m = c:ellipse(x, y, rx, ry) c:part(m, "stone", { band = 1 }) end
local function pine(x, y, h, ramp) c:fillMask(c:poly{ {x, y - h}, {x - h // 3 - 2, y}, {x + h // 3 + 2, y} }, ramp) R(x, y, x, y + 2, P.wood.deep) end

-- STREAM (mid): winding, drawn before objects on it
local pts = { {140,46},{130,48},{122,60},{125,75},{130,90},{112,102},{92,112},{72,122},{66,138},{78,152},{78,170},{70,185},{66,199} }
c:fillMask(c:line(pts, 6), P.sea.shade)
c:fillMask(c:line(pts, 4), P.sea.base)
for i = 1, #pts - 1 do c:px(pts[i][1] - 1, pts[i][2] + 1, P.sea.hi) c:px(pts[i][1], pts[i][2] + 1, P.sea.hi) end

-- ROW 0
-- (0,0) red maple
tree(32, 36, "ember", 1.1)
-- (1,0) snowy mountain is far plane; add boulders + gold bush at foot
stone(62, 49, 5, 3) stone(70, 50, 3, 2) E(86, 47, 6, 4, P.gold.base) E(85, 45, 3, 2, P.gold.hi)
-- (2,0) sugar shack with steam
do
  local w = c:rect(104, 36, 128, 49) local rf = c:poly{ {102, 37}, {116, 27}, {130, 37} }
  rim(w:copy():add(rf), P.wood.deep)
  c:part(w, "wood") c:part(rf, "stone", { band = 3 })
  R(112, 41, 118, 49, P.wood.deep) c:fillMask(c:rect(121, 40, 125, 44), P.gold.hi) -- door + window
  c:part(c:rect(108, 22, 111, 31), "stone", { band = 1, nopop = true })
  E(110, 18, 3, 2, P.cream) E(114, 13, 4, 3, P.cream) E(120, 8, 4, 3, P.stone.hi)  -- steam
  R(121, 50, 125, 52, P.wood.base) -- bucket
end
-- (3,0) gold maple + falling leaves
tree(172, 34, "gold", 1.2) c:px(184, 36, P.ember.base) c:px(188, 40, P.gold.base) c:px(160, 44, P.ember.base) c:px(178, 47, P.ember.hi)
-- (4,0) pine grove
pine(210, 48, 14, P.moss.deep) pine(222, 49, 18, P.moss.shade) pine(234, 48, 12, P.moss.deep)
-- (5,0) red barn
do
  local w = c:rect(262, 36, 286, 49) local rf = c:poly{ {260, 37}, {274, 28}, {288, 37} }
  rim(w:copy():add(rf), P.ember.deep)
  c:part(w, "ember") c:part(rf, "wood", { band = 3 })
  R(270, 41, 278, 49, P.cream) R(274, 41, 274, 49, P.ember.shade) c:px(274, 33, P.cream) c:px(275, 33, P.cream)
end

-- ROW 1
-- (0,1) pumpkin patch
pumpkin(14, 72, 6) pumpkin(30, 80, 5) pumpkin(8, 88, 4) pumpkin(38, 66, 4)
c:fillMask(c:line({ {14, 78}, {22, 84}, {30, 86} }, 1), P.moss.shade) E(24, 90, 3, 2, P.moss.base)
-- (1,1) scarecrow
R(74, 60, 74, 86, P.wood.deep) R(64, 68, 84, 68, P.wood.deep)
E(74, 62, 4, 4, P.gold.hi) R(69, 57, 79, 58, P.wood.base) R(71, 53, 77, 57, P.wood.shade) R(72, 64, 76, 64, P.ink)
R(70, 69, 78, 78, P.petal.base) R(70, 70, 78, 70, P.petal.shade) R(66, 69, 69, 69, P.gold.base) R(79, 69, 82, 69, P.gold.base) c:px(73, 62, P.ink) c:px(76, 62, P.ink)
-- (2,1) FOOTBRIDGE + BEAR (hero)
do
  local deck = c:rrect(108, 66, 142, 71, 1)
  rim(deck, P.wood.deep)
  c:part(c:rect(111, 71, 112, 80), "wood", { band = 1, nopop = true }) c:part(c:rect(138, 71, 139, 80), "wood", { band = 1, nopop = true })
  c:part(deck, "wood", { band = 2 })
  R(110, 62, 110, 66, P.wood.deep) R(140, 62, 140, 66, P.wood.deep) R(110, 62, 140, 62, P.wood.hi)
  for x = 114, 136, 6 do R(x, 62, x, 66, P.wood.shade) end
  -- bear fishing under the bridge, on the left bank
  local bx, by = 114, 80
  c:part(c:ellipse(bx, by, 5, 5), { hi = P.wood.hi, base = P.wood.shade, shade = P.wood.deep, deep = P.ink }, { band = 1, nopop = true })
  c:part(c:ellipse(bx + 2, by - 6, 3, 3), { hi = P.wood.hi, base = P.wood.shade, shade = P.wood.deep, deep = P.ink }, { band = 1, nopop = true })
  c:px(bx, by - 9, P.wood.deep) c:px(bx + 4, by - 9, P.wood.deep)
  R(bx - 1, by - 4, bx + 5, by - 3, P.ember.base) c:px(bx - 2, by - 3, P.ember.base) c:px(bx - 2, by - 2, P.ember.shade) -- scarf
  c:px(bx + 3, by - 7, P.ink) c:px(bx + 5, by - 6, P.ink)
  c:fillMask(c:line({ {bx + 5, by - 1}, {bx + 14, by - 12} }, 1), P.wood.hi)  -- rod
  c:fillMask(c:line({ {bx + 14, by - 12}, {bx + 14, by - 1} }, 1), P.cream)  -- line
  c:px(bx + 14, by, P.ember.base)
  E(bx + 17, by + 4, 2, 1, P.gold.base) -- fish
end
-- (3,1) pond with lily pads
E(175, 78, 16, 9, P.sea.shade) E(175, 78, 14, 7, P.sea.base) E(170, 75, 4, 1, P.sea.hi)
E(180, 82, 3, 2, P.moss.base) E(168, 80, 3, 1, P.moss.base) c:px(180, 80, P.petal.base) c:px(181, 80, P.petal.hi)
-- (4,1) big mushroom
R(224, 76, 227, 88, P.cream)
do local m = c:ellipse(225.5, 74, 9, 6):clip(c:rect(200, 60, 260, 77)) rim(m, P.ember.deep) c:part(m, "ember", { band = 2 })
  c:px(221, 72, P.cream) c:px(222, 72, P.cream) c:px(229, 71, P.cream) c:px(230, 71, P.cream) c:px(225, 69, P.cream) end
E(212, 86, 2, 2, P.petal.base) E(240, 84, 2, 2, P.dusk.hi)
-- (5,1) tall red maple + leaf drift
tree(276, 66, "ember", 1.3) E(290, 92, 6, 2, P.gold.base) c:px(266, 88, P.ember.base)

-- ROW 2
-- (0,2) birch grove
for i, x in ipairs{ 10, 22, 34, 44 } do
  c:part(c:rect(x, 114 + (i % 2) * 2, x + 2, 138), BIRCH, { band = 1, nopop = true }) R(x, 122, x + 1, 122, P.ink) R(x + 1, 130, x + 2, 130, P.ink)
  local m = c:ellipse(x + 1, 112 + (i % 2) * 2, 6, 6) c:part(m, "gold", { band = 2 })
end
-- (1,2) stepping stones across stream + reeds
stone(70, 124, 3, 2) stone(76, 128, 3, 2) stone(82, 131, 3, 2) stone(60, 134, 3, 2)
for x = 56, 62, 3 do R(x, 116, x, 124, P.moss.deep) E(x, 115, 1, 2, P.wood.base) end
-- (2,2) leaf pile + rake
do local m = c:ellipse(124, 130, 14, 8):clip(c:rect(100, 112, 150, 134)) rim(m, P.ember.deep) c:part(m, "ember", { band = 3 })
  E(120, 124, 6, 3, P.gold.base) E(130, 127, 5, 2, P.gold.hi) c:px(115, 130, P.gold.base)
  R(138, 114, 138, 134, P.wood.base) R(134, 114, 142, 114, P.wood.deep) end
-- (3,2) log cabin
do
  local w = c:rect(162, 122, 188, 137) local rf = c:poly{ {159, 123}, {175, 112}, {191, 123} } local ch = c:rect(181, 108, 185, 118)
  rim(w:copy():add(rf):add(ch), P.wood.deep)
  c:part(ch, "stone", { band = 1, nopop = true }) c:part(w, "wood") c:part(rf, "dusk", { band = 3 })
  for y = 126, 134, 4 do R(162, y, 188, y, P.wood.deep) end
  R(170, 128, 175, 137, P.wood.deep) R(180, 127, 185, 131, P.gold.hi) E(184, 102, 3, 2, P.stone.hi)
end
-- (4,2) hay stacks
for _, h in ipairs{ {214, 130, 9}, {232, 134, 7}, {222, 120, 6} } do
  local m = c:ellipse(h[1], h[2], h[3], h[3] - 1):clip(c:rect(190, 100, 250, h[2] + 4)) rim(m, P.gold.deep) c:part(m, "gold", { band = 2 })
  for i = -h[3] + 2, h[3] - 2, 4 do c:px(h[1] + i, h[2] - 2, P.gold.shade) c:px(h[1] + i + 1, h[2], P.gold.shade) end
end
-- (5,2) stone wall + mailbox
for i = 0, 4 do stone(262 + i * 7, 134 - (i % 2) * 2, 4, 3) end
for i = 0, 3 do stone(266 + i * 7, 128 - (i % 2), 4, 3) end
R(268, 106, 269, 122, P.wood.deep) c:part(c:rrect(262, 100, 276, 107, 2), "ember", { band = 1 }) R(276, 98, 276, 103, P.gold.base) E(288, 118, 2, 2, P.petal.base) E(284, 112, 2, 2, P.dusk.hi)

-- ROW 3
-- (0,3) apple tree
tree(26, 168, "moss", 1.3) for _, a in ipairs{ {19, 163}, {30, 160}, {36, 166}, {24, 170}, {14, 168} } do R(a[1], a[2], a[1] + 1, a[2] + 1, P.ember.base) end
-- (1,3) pond bend w/ duck
E(74, 176, 12, 7, P.sea.shade) E(74, 176, 10, 5, P.sea.base) E(70, 174, 3, 1, P.sea.hi)
E(76, 176, 3, 2, P.gold.hi) R(78, 173, 80, 174, P.gold.hi) c:px(81, 174, P.ember.base) c:px(79, 173, P.ink)
-- (2,3) tent + campfire
do
  local t = c:poly{ {102, 190}, {116, 168}, {130, 190} }
  rim(t, P.dusk.deep) c:part(t, "dusk", { band = 3 }) c:fillMask(c:poly{ {116, 178}, {111, 190}, {121, 190} }, P.dusk.deep) c:px(116, 168, P.gold.base)
  c:fillMask(c:poly{ {136, 190}, {139, 183}, {142, 190} }, P.ember.base) c:fillMask(c:poly{ {138, 190}, {139, 186}, {141, 190} }, P.gold.hi)
  R(134, 191, 144, 191, P.wood.deep)
end
-- (3,3) dark pines
pine(165, 190, 22, P.moss.deep) pine(178, 192, 28, P.moss.shade) pine(191, 190, 18, P.moss.deep) c:fillMask(c:poly{ {178, 164}, {174, 172}, {182, 172} }, P.stone.hi)
-- (4,3) pumpkin cart
do
  local b = c:rect(210, 176, 238, 186) rim(b, P.wood.deep) c:part(b, "wood", { band = 2 })
  pumpkin(216, 174, 4) pumpkin(224, 173, 5) pumpkin(233, 174, 4)
  E(214, 189, 4, 4, P.wood.deep) E(214, 189, 1, 1, P.gold.base) E(234, 189, 4, 4, P.wood.deep) E(234, 189, 1, 1, P.gold.base)
end
-- (5,3) signpost + flower patch
R(276, 166, 277, 190, P.wood.deep) do local s = c:rect(268, 168, 288, 175) rim(s, P.wood.deep) c:part(s, "wood", { band = 1 }) end R(272, 171, 284, 171, P.wood.deep)
for _, f in ipairs{ {262, 186}, {270, 192}, {283, 188}, {290, 194}, {296, 184}, {256, 193} } do
  R(f[1] - 1, f[2], f[1] + 1, f[2], P.petal.base) R(f[1], f[2] - 1, f[1], f[2] + 1, P.petal.base) c:px(f[1], f[2], P.gold.hi)
end

-- NEAR plane: ink-edged foliage + grass framing the corners
local function leaf(x, y, hex) local m = c:ellipse(x, y, 7, 4) rim(m, P.ink) c:fillMask(m, hex) R(x - 6, y, x + 6, y, P.moss.deep) end
leaf(4, 195, P.moss.base) leaf(14, 198, P.moss.shade) leaf(296, 196, P.ember.base) leaf(286, 199, P.gold.base)
leaf(150, 199, P.moss.base) leaf(4, 46, P.gold.base)
for _, x in ipairs{ 24, 46, 96, 124, 160, 202, 246 } do R(x, 198, x, 199, P.moss.deep) R(x + 2, 197, x + 2, 199, P.moss.deep) end

HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "region-maplewold.aseprite", png = out .. "region-maplewold.png", scale = 6 }
