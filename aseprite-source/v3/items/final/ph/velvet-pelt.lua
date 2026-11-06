-- velvet-pelt (lean D3o_8)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan

local c = HP.canvas{ w=64, h=64, scale=1, name="velvet-pelt" }
local VEL = { "#25143f", "#3c2060", "#5a3290", "#7a4ab8", "#9c6fd6", "#c3a2ee" }
local THR = { "#8a6a1e", "#c9a23a", "#f2d46a" }
c:groundShadow(33, 56, 17, 2)
local hide = c:ellipse(32, 32, 14, 11)
hide:add(c:ellipse(15, 21, 6, 5)):add(c:ellipse(23, 22, 9, 8))          -- neck+head blob
hide:add(c:ellipse(21, 46, 4, 7)):add(c:ellipse(43, 47, 4, 7))          -- hind/fore legs
hide:add(c:ellipse(46, 20, 5, 6)):add(c:ellipse(17, 40, 4, 5))
hide:add(c:ellipse(49, 33, 6, 4)):add(c:ellipse(53, 31, 3, 3))          -- tail
hide:add(c:ellipse(10, 15, 2, 3)):add(c:ellipse(17, 13, 2, 3))          -- ears
-- furry edge
local rough = hide:copy()
hide:edge():each(function(x, y) if X.hash(x, y, 5) > 0.72 then rough.s[K(x, y)] = nil end end)
hide = rough
local n = X.pillow(hide, 8)
local v = X.light(n, { amb = 0.12, wrap = 0.3 })
local bias = {}
hide:each(function(x, y) local k = K(x, y)
  local h = X.hash(x, y, 9)
  if (x + 2 * y) % 4 == 0 and h > 0.55 then bias[k] = 1
  elseif (x + 2 * y) % 4 == 2 and h > 0.6 then bias[k] = -1 end
end)
G.tone(c, hide, v, VEL, { 0.18, 0.36, 0.52, 0.68, 0.84 }, bias)
-- nap sheen along lit shoulder
hide:each(function(x, y) if v[K(x, y)] > 0.62 and (x + 2*y) % 5 == 0 and X.hash(x, y, 2) > 0.4 then c:px(x, y, VEL[6]) end end)
-- eyes closed / nose
c:px(12, 21, VEL[1]) c:px(13, 21, VEL[1]) c:px(9, 22, VEL[1])
-- quirk: gold-thread cross-stitched patch
local patch = c:rect(32, 28, 40, 35)
G.tone(c, patch, X.light(X.pillow(patch, 5), { amb = 0.3, wrap = 0.3 }), { "#4a2c52", "#6e3f6a", "#965888", "#c07fb0" }, { 0.3, 0.55, 0.8 })
for x = 32, 40 do c:px(x, 28, THR[2]) c:px(x, 35, THR[1]) end
for y = 28, 35 do c:px(32, y, THR[2]) c:px(40, y, THR[1]) end
for i = 0, 3 do c:px(34 + i, 30 + i, THR[3]) c:px(37 - i, 30 + i, THR[2]) end
G.fin(c, "velvet-pelt")
