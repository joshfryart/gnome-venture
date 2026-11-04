-- holly-hedge (lean W2_7)
-- A plump cloud-shaped holly hedge on two stubby posts: spiky leaf-edge, berry clusters, a robin perched on top (quirk).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "holly-hedge" }
local LEAF = { "#10302c", "#1b4a35", "#2b6a3c", "#43883f", "#6aa84a", "#a4d06a" }
local RED  = { "#4a0f1f", "#7d1428", "#b3202f", "#d93a38", "#f26a50", "#ffc0a0" }
local WOOD = { "#3a2418", "#5a3a22", "#7e5430", "#a1713f" }
local BRN  = { "#3b2418", "#5e3a24", "#8a5a36", "#b88556" }
c:groundShadow(32, 52, 20, 3)
-- posts
for _, x0 in ipairs{ 19, 41 } do
  local p = c:rect(x0, 44, x0 + 3, 51)
  c:part(p, WOOD)
  c:fillMask(c:rect(x0, 44, x0 + 3, 45), WOOD[1])
  c:px(x0 + 1, 48, WOOD[4])
end
-- hedge body: union of lobes
local m = HP.mask()
for _, L in ipairs{ {21,31,10,11}, {43,31,10,11}, {32,25,13,12}, {32,36,17,9} } do m:add((G.oval(L[1], L[2], L[3], L[4], 0, 1))) end
local ring = m:copy():grow(1):cut(m)
ring:each(function(x, y) if X.hash(x, y, 5) > 0.7 and y < 40 then m:set(x, y) end end)
local n = X.pillow(m, 9)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
local bias = {}
X.tone(c, m, v, LEAF, { cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias = bias })
-- holly leaf texture: pale spiky glints and dark notches
m:each(function(x, y)
  local h = X.hash(x, y, 3)
  local k = K(x, y)
  if h > 0.88 and v[k] > 0.45 then c:px(x, y, LEAF[6])
  elseif h > 0.80 and v[k] > 0.3 and X.hash(x + 1, y, 3) > 0.8 then c:px(x, y, LEAF[5])
  elseif h < 0.1 then c:px(x, y, LEAF[1]) end
  if (x + y * 2) % 7 == 0 and h > 0.35 and v[k] > 0.25 then c:px(x, y, LEAF[2]) end
end)
-- berries
for _, b in ipairs{ {16,28},{20,36},{25,29},{30,38},{34,31},{40,27},{45,35},{49,30},{38,40},{12,34},{28,22} } do
  local bm, bn = G.oval(b[1], b[2], 1.9, 1.9, 0, 1)
  G.toneN(c, bm, bn, RED)
  c:px(b[1] - 1, b[2] - 1, RED[6])
  c:px(b[1] + 1, b[2] + 1, RED[1])
end
-- robin on top (quirk)
local bd, bdn = G.oval(38, 11, 4.2, 3.2, 0, 1)
G.toneN(c, bd, bdn, BRN)
local hd, hdn = G.oval(42, 8, 2.6, 2.6, 0, 1)
G.toneN(c, hd, hdn, BRN)
for _, p in ipairs{ {41,10},{42,10},{43,10},{42,11},{41,11},{40,12},{41,12} } do c:px(p[1], p[2], "#e8683a") end
c:px(42, 9, "#f58a4a")
c:px(42, 7, "#1a1018") c:px(44, 8, "#f2c14a") c:px(45, 8, "#f2c14a")
c:px(33, 11, BRN[2]) c:px(34, 12, BRN[1]) c:px(33, 12, BRN[1]) c:px(34, 10, BRN[3])
c:px(37, 9, BRN[4])
G.save(c, "holly-hedge")
