-- stage-backdrop FIRST DRAFT. Draw 190x115, save x2 = 380x230. Meadow with a mushroom fairy ring as the stage.
-- Centre (x 55-135 of 190) kept low-contrast and nearly empty: a 160x200 gnome stands there.
-- quirk: one toadstool in the ring is blue-spotted and wears a tiny acorn cap; a snail rides the left edge.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = "stage-backdrop"
local c = HP.canvas{ w = 190, h = 115, scale = 2, name = NAME }
local sin, cos, abs, floor, pi = math.sin, math.cos, math.abs, math.floor, math.pi
local seed = 7
local function rnd() seed = (seed * 1103515245 + 12345) % 2147483648 return seed / 2147483648 end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local function edge(x) return x < 52 or x > 138 end

-- sky
c:stripes(0, 52, { P.sky.shade, P.sky.base, P.sky.hi, "#f1fbff" }, { 3, 4, 4, 3 })
c:cloud(10, 22, 26, P.cream, P.sky.hi)
c:cloud(150, 16, 28, P.cream, P.sky.hi)
c:cloud(168, 36, 14, P.cream, P.sky.hi)
c:fillMask(E(172, 8, 6, 6), P.gold.hi) c:fillMask(E(172, 8, 4, 4), P.cream)
-- far hills (low contrast)
c:terrain(function(x) return 44 + 7 * sin(x / 26 + .6) + 3 * sin(x / 9) end, "#a9dccb")
c:terrain(function(x) return 54 + 5 * sin(x / 21 + 2) + 2 * sin(x / 7) end, P.moss.hi)
-- edge trees on the far hills
local function tree(x, y, s)
  R(x - 1, y, x, y + 8 * s, P.wood.shade)
  c:fillMask(E(x, y - 2, 5 * s, 5 * s), P.moss.shade)
  c:fillMask(E(x - 1, y - 3, 3 * s, 3 * s), P.moss.base)
end
tree(12, 50, 1) tree(24, 52, 1) tree(170, 52, 1) tree(182, 49, 1)
-- meadow
c:terrain(function(x) return 62 + 2 * sin(x / 30 + 1) end, P.moss.base)
c:terrain(function(x) return 80 + 3 * sin(x / 22) end, "#6fb955")
-- grass tufts: dense at edges, sparse low-contrast in the centre
for i = 1, 160 do
  local x, y = floor(rnd() * 190), 64 + floor(rnd() * 50)
  local col = edge(x) and P.moss.shade or "#70b957"
  c:px(x, y, col) c:px(x + 1, y - 1, col) if edge(x) then c:px(x - 1, y - 1, col) end
end
-- stepping path leaving at the bottom edge, off-centre
for i, s in ipairs{ {150, 108}, {158, 112} } do c:fillMask(E(s[1], s[2], 6, 2), P.wood.hi) c:fillMask(E(s[1] + 1, s[2] + 1, 5, 1), "#d9a870") end

-- the ring: inner lawn oval
local RCX, RCY, RX, RY = 95, 92, 54, 15
c:fillMask(E(RCX, RCY, RX - 6, RY - 4), "#86cb60")
-- toadstools, ring order back to front
local function toad(x, y, s, muted, blue)
  local cap = HP.mask():add(E(x, y, 3 * s, 2 * s)):clip(c:rect(x - 3 * s, y - 2 * s, x + 3 * s, y))
  local stem = c:rect(x - floor(s * .8), y, x + floor(s * .8), y + 2 * s)
  c:fillMask(E(x, y + 2 * s + 1, 3 * s, 1), "#5aa24a")
  c:part(stem, { hi = P.cream, base = P.cream, shade = "#ead7b4", deep = "#c9b48e" }, { noshade = s < 2, nopop = true, inner = false })
  local ramp = muted and { hi = "#e57a62", base = "#d4574d", shade = "#a8404b", deep = "#6e2038" } or "ember"
  c:rim(cap, P.ember.deep)
  c:part(cap, ramp, { band = 1, nopop = true, inner = false })
  local sp = blue and "#bfe8ff" or P.cream
  c:px(x - s, y - s, sp)
  if s >= 2 then c:px(x + s + 1, y - 2, sp) c:px(x + 1, y - 3, sp) c:px(x - 2 * s, y - 1, sp) end
end
local N = 14
local list = {}
for i = 0, N - 1 do
  local a = i / N * 2 * pi
  list[#list + 1] = { x = floor(RCX + cos(a) * RX + .5), y = floor(RCY + sin(a) * RY + .5), a = a, i = i }
end
table.sort(list, function(p, q) return p.y < q.y end)
for _, t in ipairs(list) do
  local centre = abs(t.x - RCX) < 38
  local s = centre and 1 or 2
  if t.y > RCY + 6 then s = centre and 2 or 3 end
  if t.y > RCY + 6 and centre then s = 2 end
  toad(t.x, t.y, s, centre, t.i == 5)
end
-- quirk: acorn cap on the blue-spotted toadstool
for _, t in ipairs(list) do
  if t.i == 5 then c:fillMask(c:rect(t.x - 1, t.y - 6, t.x + 1, t.y - 5), P.wood.base) c:px(t.x, t.y - 7, P.wood.deep) end
end
-- flowers at the edges
local function flower(x, y, col, s)
  c:px(x, y + 1, P.moss.shade) c:px(x, y + 2, P.moss.shade) if s > 1 then c:px(x, y + 3, P.moss.shade) c:px(x - 1, y + 2, P.moss.base) end
  c:px(x, y, P[col].hi) c:px(x - 1, y, P[col].base) c:px(x + 1, y, P[col].base) c:px(x, y - 1, P[col].base) c:px(x, y + 1 - (s > 1 and 0 or 1), P[col].shade)
  c:px(x, y, P.gold.base)
end
local cols = { "petal", "gold", "dusk", "ember", "sea" }
for i = 1, 46 do
  local x = floor(rnd() * 190)
  if edge(x) then flower(x, 66 + floor(rnd() * 46), cols[1 + i % 5], 1 + i % 2) end
end
-- big foreground flowers/grass in the bottom corners
for _, f in ipairs{ {6, 100}, {16, 108}, {28, 104}, {176, 102}, {184, 110}, {166, 108} } do
  flower(f[1], f[2], cols[1 + (f[1] % 5)], 2)
  c:px(f[1] - 2, f[2] + 4, P.moss.base) c:px(f[1] + 2, f[2] + 4, P.moss.base)
end
-- snail on the left edge
c:fillMask(E(14, 92, 3, 3), P.gold.shade) c:px(13, 91, P.gold.hi) c:px(14, 92, P.gold.deep)
c:fillMask(c:rect(9, 94, 18, 95), "#d9c2a0") c:px(8, 93, "#d9c2a0") c:px(8, 92, P.ink)
-- butterflies
local function fly(x, y, col)
  c:px(x, y, col.base) c:px(x - 1, y - 1, col.base) c:px(x - 2, y - 1, col.hi) c:px(x - 1, y, col.shade)
  c:px(x + 1, y, col.base) c:px(x + 2, y - 1, col.base) c:px(x + 3, y - 1, col.hi) c:px(x + 2, y, col.shade) c:px(x + 1, y - 1, P.ink)
end
fly(30, 66, P.petal) fly(164, 78, P.dusk) fly(146, 58, P.gold)
c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 2 }
