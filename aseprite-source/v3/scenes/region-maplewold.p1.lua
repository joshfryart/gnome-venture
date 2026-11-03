-- region-maplewold PASS 1 (form). 300x200 grid, x6 = 1800x1200 (+ 450x300 thumb at x1.5).
-- One composed autumn valley (not a checkerboard): stream falls from the far hills, winds through the
-- hamlet under a footbridge and out at the bottom; a sandy lane climbs from the bottom-right over the
-- bridge to the sugar shack. Planes: far = sky + 2-tone ridge; mid = hamlet, trees, fields;
-- near = ink-edged maple canopies (top corners) and foliage (bottom corners).
-- Jigsaw: each 50x50 cell of the 6x4 grid has its own landmark (listed per cell below).
-- quirk: a bear in a tiny scarf fishing under the footbridge.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local c = HP.canvas{ w = 300, h = 200, scale = 6, name = "region-maplewold" }
local floor, sin, cos, abs = math.floor, math.sin, math.cos, math.abs
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local PUMP = { hi = P.gold.hi, base = P.gold.base, shade = P.gold.shade, deep = P.gold.deep }

------------------------------------------------------------------ FAR
c:stripes(0, 44, { P.sky.shade, P.sky.base, P.sky.hi }, { 2, 3, 3 })
c:fillMask(E(70, 14, 7, 7), P.gold.base) c:fillMask(E(69, 13, 4, 4), P.gold.hi)
c:cloud(84, 20, 26, P.cream, P.sky.hi)
c:cloud(176, 14, 22, P.cream, P.sky.hi)
c:cloud(232, 30, 16, P.cream, P.sky.hi)
local function ridge(x) return 31 + 5 * sin(x / 26 + 1) + 3 * sin(x / 11) end
c:terrain(ridge, P.dusk.hi)
local function hill(x) return 41 + 3 * sin(x / 19 + 2) + 2 * sin(x / 8) end
c:terrain(hill, P.moss.hi)
-- far tree line: varied clusters (2 tones per cluster), gaps between
local x = 0
local k = 0
while x < 300 do
  local n = 2 + (k * 7) % 3
  local col = ({ P.ember.hi, P.gold.base, P.gold.hi, P.ember.base })[k % 4 + 1]
  for j = 0, n - 1 do
    local cx = x + j * 4 local r = 2 + (j + k) % 3
    c:fillMask(E(cx, floor(hill(cx)) - r + 2, r, r), col)
  end
  x = x + n * 4 + 4 + (k * 5) % 7
  k = k + 1
end
------------------------------------------------------------------ MID ground
local function ground(x) return 46 + 2 * sin(x / 15) end
c:terrain(ground, P.moss.base)
-- meadow / leaf-litter / field patches (irregular, hue varies)
local patches = {
  { 30, 92, 24, 8, P.moss.hi }, { 252, 86, 28, 8, P.gold.hi }, { 190, 128, 28, 12, P.moss.hi },
  { 212, 74, 22, 8, P.moss.hi }, { 20, 172, 26, 12, P.gold.hi }, { 262, 162, 26, 12, P.gold.base },
  { 100, 66, 18, 6, P.moss.hi }, { 180, 188, 24, 8, P.moss.hi },
}
for i, p in ipairs(patches) do
  local m = E(p[1], p[2], p[3], p[4]):add(E(p[1] - p[3] * .5, p[2] + p[4] * .4, p[3] * .5, p[4] * .7)):add(E(p[1] + p[3] * .55, p[2] - p[4] * .3, p[3] * .45, p[4] * .6))
  c:fillMask(m, p[5])
end
-- ploughed pumpkin field (r2 c0-c1)
local field = c:poly{ {0, 104}, {70, 100}, {92, 120}, {80, 146}, {0, 150} }
c:fillMask(field, P.wood.base)
for y = 106, 146, 6 do c:fillMask(c:line({ {0, y}, {90 - (y - 100) * 0.2, y - 3} }, 1):clip(field), P.wood.shade) end

-- stream: waterfall from the ridge, winding to the bottom
local sp = { {150, 34}, {148, 46}, {138, 58}, {128, 72}, {132, 88}, {140, 104}, {146, 118}, {136, 134}, {116, 148}, {96, 162}, {86, 180}, {82, 199} }
local water = HP.mask()
for i = 1, #sp - 1 do
  local w = 2 + floor(i * 0.6)
  water:add(c:line({ sp[i], sp[i + 1] }, w))
end
c:rim(water, P.sea.shade)
c:fillMask(water, P.sea.base)
for i = 3, #sp - 1, 2 do c:px(sp[i][1] - 1, sp[i][2] + 2, P.sea.hi) c:px(sp[i][1], sp[i][2] + 2, P.sea.hi) end
R(148, 33, 152, 44, P.sky.hi) R(150, 33, 150, 44, P.sea.hi) -- waterfall (r0 c2)

-- sandy lane: bottom-right up to the bridge, then to the sugar shack
local lane = c:line({ {214, 199}, {208, 180}, {194, 160}, {176, 140}, {164, 118}, {160, 108} }, 7)
lane:add(c:line({ {120, 104}, {104, 96}, {88, 88}, {80, 84} }, 5))
c:fillMask(lane, P.wood.hi)
c:rim(lane, P.gold.shade, c:rect(0, 0, 299, 199):cut(water))

------------------------------------------------------------------ helpers
local function maple(x, y, s, ramp, ink)
  local tr = c:poly{ {x - 2, y}, {x + 2, y}, {x + 1, y - 8 * s}, {x - 1, y - 8 * s} }
  local cr = E(x, y - 12 * s, 9 * s, 7 * s):add(E(x - 7 * s, y - 8 * s, 6 * s, 5 * s)):add(E(x + 7 * s, y - 8 * s, 6 * s, 5 * s))
    :add(E(x - 3 * s, y - 17 * s, 5 * s, 4 * s)):add(E(x + 4 * s, y - 16 * s, 5 * s, 4 * s))
  if ink then c:rim(tr:copy():add(cr), P.ink) else c:rim(cr, P[ramp].deep) end
  c:part(tr, "wood", { band = 1, nopop = true })
  c:part(cr, ramp, { band = 3 })
  return cr
end
local function pumpkin(x, y, r)
  local m = E(x, y, r + 1, r)
  c:part(m, PUMP, { band = 1 })
  if r >= 3 then R(x, y - r + 1, x, y + r - 1, P.gold.shade) end
  R(x, y - r - 2, x, y - r, P.moss.deep)
end
local function deepEdge(m, hex) c:rim(m, hex) end

------------------------------------------------------------------ r0 (sky row)
-- c0: near gold maple canopy (top-left frame) -- drawn last (near)
-- c1: sun + geese V
for i, g in ipairs{ {56, 30}, {59, 28}, {62, 26}, {65, 28}, {68, 30}, {53, 32} } do c:px(g[1], g[2], P.ink) c:px(g[1] + 1, g[2] - 1, P.ink) end
-- c2: waterfall (above) + cloud
-- c3: windmill on the far hill
do
  local tw = c:poly{ {182, 44}, {190, 44}, {188, 30}, {184, 30} } c:fillMask(tw, P.cream)
  c:fillMask(c:poly{ {183, 31}, {186, 25}, {189, 31} }, P.ember.base)
  for _, b in ipairs{ { -9, -6 }, { 7, -8 }, { 9, 6 }, { -7, 8 } } do c:fillMask(c:line({ {186, 28}, {186 + b[1], 28 + b[2]} }, 2), P.wood.shade) end
  R(185, 38, 187, 44, P.wood.shade)
end
-- c4: hot-air balloon
do
  local b = E(226, 14, 8, 9) c:part(b, "ember", { band = 2 })
  for x = 220, 232, 4 do c:fillMask(c:rect(x, 6, x + 1, 23):clip(b), P.gold.base) end
  c:fillMask(c:line({ {221, 21}, {224, 27} }, 1), P.wood.deep) c:fillMask(c:line({ {231, 21}, {228, 27} }, 1), P.wood.deep)
  c:part(c:rect(223, 27, 229, 31), "wood", { band = 1, nopop = true })
end

------------------------------------------------------------------ r1
-- c0: gold maple + swing (trunk of the near canopy comes later; this is a mid maple)
maple(28, 92, 1.3, "gold")
c:fillMask(c:line({ {18, 80}, {18, 94} }, 1), P.wood.deep) c:fillMask(c:line({ {26, 80}, {26, 94} }, 1), P.wood.deep) R(16, 94, 28, 95, P.ember.base)
-- c1: sugar shack with steam + sap buckets (mid object, wood.deep edge)
do
  local w = c:rect(60, 66, 92, 84)
  local rf = c:poly{ {56, 67}, {76, 54}, {96, 67} }
  local cup = c:rect(72, 48, 80, 55) local cap2 = c:poly{ {70, 49}, {76, 44}, {82, 49} }
  local all = w:copy():add(rf):add(cup):add(cap2)
  deepEdge(all, P.wood.deep)
  c:part(w, "wood", { band = 2 })
  for y = 70, 82, 4 do R(60, y, 92, y, P.wood.shade) end
  c:part(rf, "ember", { band = 2 })
  c:part(cup, "wood", { band = 1, nopop = true }) c:part(cap2, "ember", { band = 1, nopop = true })
  R(74, 50, 78, 53, P.ink)
  R(80, 72, 86, 84, P.wood.deep) c:part(c:rect(64, 72, 71, 78), "gold", { band = 1 })
  for i, s in ipairs{ {76, 40, 3, 2}, {72, 34, 4, 3}, {78, 27, 5, 3}, {72, 20, 4, 3} } do c:fillMask(E(s[1], s[2], s[3], s[4]), i % 2 == 1 and P.cream or P.stone.hi) end
  -- sap barrels
  c:part(c:rect(94, 78, 99, 85), "stone", { band = 1, nopop = true }) R(94, 81, 99, 81, P.stone.deep)
end
-- c2: red maple at the stream bend
maple(108, 82, 1.0, "ember")
-- c3: red barn with gold roof
do
  local w = c:rect(162, 64, 194, 86) local rf = c:poly{ {158, 66}, {168, 52}, {188, 52}, {198, 66} }
  deepEdge(w:copy():add(rf), P.ember.deep)
  c:part(w, "ember", { band = 2 }) c:part(rf, "gold", { band = 2 })
  R(172, 72, 184, 86, P.cream) c:fillMask(c:line({ {173, 73}, {183, 85} }, 1), P.ember.shade) c:fillMask(c:line({ {183, 73}, {173, 85} }, 1), P.ember.shade)
  c:part(c:rect(175, 56, 181, 61), "wood", { band = 1, nopop = true })
end
-- c4: haystacks + sheep
for _, h in ipairs{ {214, 84, 8}, {230, 88, 6} } do
  local m = E(h[1], h[2], h[3], h[3] + 1):clip(c:rect(0, 0, 299, h[2] + 3)) c:part(m, "gold", { band = 2 })
  for i = -h[3] + 2, h[3] - 2, 3 do c:px(h[1] + i, h[2] - 1, P.gold.shade) end
end
local function sheep(x, y)
  local b = E(x, y, 4, 3) c:part(b, { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }, { band = 1, nopop = true })
  R(x + 4, y - 2, x + 6, y, P.ink) R(x - 2, y + 3, x - 2, y + 4, P.ink) R(x + 2, y + 3, x + 2, y + 4, P.ink)
end
sheep(238, 74) sheep(206, 70)
-- c5: red maple trunk (near canopy) with owl hole -- drawn with the near canopy

------------------------------------------------------------------ r2
-- c0 + c1: pumpkin field + scarecrow
for _, p in ipairs{ {10, 112, 4}, {28, 116, 5}, {48, 110, 3}, {16, 130, 5}, {40, 134, 4}, {62, 126, 4}, {6, 144, 3}, {30, 146, 3} } do pumpkin(p[1], p[2], p[3]) end
do
  R(76, 106, 77, 136, P.wood.deep) R(66, 114, 87, 115, P.wood.deep)
  c:part(c:rect(70, 115, 83, 126), "sea", { band = 1, nopop = true }) R(70, 120, 83, 120, P.sea.deep)
  c:part(E(76.5, 109, 4, 4), "gold", { band = 1 })
  c:px(75, 108, P.ink) c:px(78, 108, P.ink)
  c:fillMask(c:rect(70, 104, 83, 105), P.ember.shade) c:fillMask(c:rect(73, 100, 80, 104), P.ember.base)
  c:px(86, 112, P.ink) c:px(87, 111, P.ink) -- crow
end
-- c2 + c3: FOOTBRIDGE (hero) + BEAR (quirk)
do
  local deck = c:poly{ {120, 104}, {130, 98}, {150, 98}, {162, 104}, {162, 108}, {150, 103}, {130, 103}, {120, 108} }
  local rail = c:line({ {120, 98}, {130, 92}, {150, 92}, {162, 98} }, 1)
  local posts = HP.mask() for _, x in ipairs{ 121, 130, 140, 150, 161 } do posts:add(c:rect(x, x == 121 and 99 or x == 161 and 99 or 93, x, 104)) end
  local br = deck:copy():add(rail):add(posts)
  deepEdge(br, P.wood.deep)
  c:part(deck, "wood", { band = 2 }) c:fillMask(rail, P.wood.base) c:fillMask(posts, P.wood.shade)
  for x = 124, 158, 4 do c:fillMask(c:rect(x, 98, x, 108):clip(deck), P.wood.shade) end
  -- bear on the west bank, south of the bridge
  local BR = { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = P.ink }
  local body = E(126, 122, 7, 6) local head = E(127, 112, 5, 4)
  local ears = E(123, 108, 1, 1):add(E(131, 108, 1, 1))
  deepEdge(body:copy():add(head):add(ears), P.ink)
  c:part(body, BR, { band = 2, nopop = true }) c:part(head, BR, { band = 1, nopop = true }) c:fillMask(ears, P.wood.shade)
  c:fillMask(E(128, 114, 2, 1), P.wood.hi) c:px(128, 113, P.ink) c:px(125, 111, P.ink) c:px(130, 111, P.ink)
  R(122, 116, 132, 117, P.ember.base) R(123, 118, 124, 121, P.ember.base) c:px(124, 121, P.ember.shade) -- tiny scarf
  c:fillMask(c:line({ {132, 121}, {142, 108} }, 1), P.wood.hi)
  c:fillMask(c:line({ {142, 108}, {143, 120} }, 1), P.cream)
  c:px(143, 121, P.ember.base)
end
-- c3: lamp post + firewood stack
do
  R(174, 108, 175, 132, P.ink) c:part(c:rect(171, 102, 178, 108), "gold", { band = 1 }) R(170, 101, 179, 101, P.ink)
  local logs = HP.mask() for i = 0, 2 do for j = 0, 2 - i do logs:add(E(188 + j * 5 + i * 2.5, 132 - i * 4, 2, 2)) end end
  c:rim(logs, P.wood.deep) c:part(logs, "wood", { band = 1 })
end
-- c4: apple tree with ladder
do
  local cr = maple(234, 140, 1.25, "moss")
  for _, a in ipairs{ {226, 120}, {238, 114}, {244, 124}, {230, 130}, {218, 128}, {240, 132} } do R(a[1], a[2], a[1] + 1, a[2] + 1, P.ember.base) end
  c:fillMask(c:line({ {248, 142}, {252, 118} }, 1), P.wood.base) c:fillMask(c:line({ {253, 142}, {257, 118} }, 1), P.wood.base)
  for y = 122, 140, 4 do R(249 + (140 - y) // 6, y, 254 + (140 - y) // 6, y, P.wood.base) end
end
-- c5: wheelbarrow of pumpkins
do
  local tub = c:poly{ {262, 120}, {290, 120}, {286, 130}, {266, 130} }
  c:part(tub, "sea", { band = 2 }) pumpkin(270, 118, 3) pumpkin(280, 117, 4)
  c:part(E(266, 133, 3, 3), "stone", { band = 1, nopop = true }) R(286, 128, 296, 132, P.wood.shade)
end

------------------------------------------------------------------ r3
-- c1: cattails + duck on the stream
for _, x in ipairs{ 70, 74, 78, 102 } do R(x, 164, x, 176, P.moss.deep) R(x, 162, x, 166, P.wood.shade) end
do c:fillMask(E(92, 176, 3, 2), P.cream) c:fillMask(E(95, 172, 2, 2), P.moss.shade) c:px(97, 172, P.gold.base) end
-- c2: log over the bank + frog on a lily pad
do local lg = c:rect(104, 182, 126, 186) c:part(lg, "wood", { band = 1 }) c:fillMask(E(104, 184, 2, 2), P.wood.hi) end
c:fillMask(E(92, 190, 4, 2), P.moss.base) c:fillMask(E(92, 188, 2, 1), P.moss.hi)
-- c3: signpost
do
  R(160, 166, 161, 192, P.wood.deep)
  c:part(c:poly{ {150, 168}, {170, 168}, {174, 171}, {170, 174}, {150, 174} }, "wood", { band = 1 })
  c:part(c:poly{ {154, 177}, {170, 177}, {170, 183}, {154, 183}, {150, 180} }, "wood", { band = 1 })
end
-- c4: big pumpkins + crate
pumpkin(232, 182, 7) pumpkin(247, 188, 5)
c:part(c:rect(216, 176, 224, 186), "wood", { band = 1 })

------------------------------------------------------------------ NEAR (ink-edged frame)
-- top-left gold canopy (r0 c0)
do
  local cr = E(10, 6, 30, 18):add(E(40, 2, 14, 10)):add(E(4, 30, 14, 12)):add(E(28, 22, 12, 9))
  c:rim(cr, P.ink) c:part(cr, "gold", { band = 3 })
  for _, l in ipairs{ {20, 10}, {8, 24}, {34, 8}, {16, 34} } do R(l[1], l[2], l[1] + 1, l[2], P.gold.hi) end
end
-- top-right red maple canopy + trunk with owl hole (r0 c5, r1 c5)
do
  local tr = c:poly{ {280, 110}, {296, 110}, {294, 30}, {284, 30} }
  local cr = E(290, 8, 30, 20):add(E(262, 4, 14, 10)):add(E(296, 34, 12, 14)):add(E(272, 26, 12, 8))
  c:rim(tr:copy():add(cr), P.ink)
  c:part(tr, "wood", { band = 3, nopop = true })
  c:part(cr, "ember", { band = 3 })
  c:fillMask(E(289, 70, 3, 4), P.wood.deep) c:px(288, 69, P.gold.hi) c:px(290, 69, P.gold.hi)
end
-- bottom-left ferns/leaves + mushrooms (r3 c0)
do
  local f = E(8, 196, 22, 12):add(E(34, 200, 14, 8))
  c:rim(f, P.ink) c:part(f, "moss", { band = 3 })
  local mu = E(46, 180, 5, 3):clip(c:rect(0, 0, 299, 180)) local st = c:rect(45, 181, 47, 186)
  c:rim(mu:copy():add(st), P.ink) c:fillMask(st, P.cream) c:part(mu, "ember", { band = 1 })
  c:px(44, 178, P.cream)
end
-- bottom-right gold bush (r3 c5)
do
  local b = E(290, 190, 22, 16):add(E(268, 198, 12, 6))
  c:rim(b, P.ink) c:part(b, "gold", { band = 3 })
  for _, l in ipairs{ {280, 182}, {294, 178}, {286, 192} } do c:px(l[1], l[2], P.ember.base) c:px(l[1] + 1, l[2], P.ember.base) end
end

HP.report(c) HP.assertClean(c)
HP.cells(c, 6, 4)
c:save{ aseprite = out .. "region-maplewold.p1.aseprite", png = out .. "region-maplewold.p1.png", scale = 6 }
