-- stirrup-hoe (lean D2o_13)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function pick(r, v) return r[max(1, min(#r, floor(v * #r) + 1))] end
local WOOD  = { "#3a2218", "#5c3a26", "#80522f", "#a8733d", "#cf9a55", "#ecc57e" }
local STEEL = { "#2c3040", "#4a5068", "#6d7690", "#94a0b8", "#c0cad8", "#eef2f6" }
local GOLD  = { "#5a3414", "#8a5a1a", "#b88426", "#dcae3a", "#f2d05a", "#fff0a0" }
local STONE = { "#3a3644", "#57536a", "#78748a", "#9a96a8", "#bcb8c4", "#dcd8e0" }
local WARM  = { "#4a3a38", "#6e5a52", "#917a6a", "#b49c88", "#d3bea8", "#ecdcc8" }
local MAUVE = { "#44304a", "#654666", "#876088", "#a8809f", "#c9a4b8", "#e6c8d4" }
local MOSS  = { "#1f3d2a", "#2f5c34", "#4a7f3c", "#75a64a", "#a2c862" }
local RED   = { "#4a1224", "#7a1c34", "#a82c40", "#d04a4c", "#ec7a64", "#ffb090" }
local function paint(m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R); local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, nil, o.bias, nil); return v end
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stirrup-hoe" }
local hm, hn, T = G.tube({ {17,52}, {23,40}, {30,28}, {38,17} }, function(t) return 1.9 end)
local v = X.light(hn, { amb = 0.12, wrap = 0.3 })
G.tone(c, hm, v, WOOD, nil, nil, nil)
hm:each(function(x, y) local k = K(x, y)
  if T[k] < 0.3 and floor(T[k] * 70) % 3 == 0 then c:px(x, y, v[k] > 0.5 and RED[4] or RED[2])
  elseif X.hash(x, y, 3) > 0.9 and T[k] > 0.3 then c:px(x, y, WOOD[2]) end end)
paint(c:ellipse(15, 54, 3, 3), WOOD, 3)
-- stirrup loop blade
local outer = c:rrect(35, 5, 56, 19, 4)
local inner = c:rrect(40, 9, 51, 15, 2)
local ring = outer:copy():cut(inner)
paint(ring, STEEL, 2)
ring:each(function(x, y) if y == 18 or y == 19 then c:px(x, y, STEEL[6]) end end)
c:fillMask(c:rect(40, 5, 46, 5), STEEL[5])
-- socket collar where handle meets
paint(c:rect(34, 17, 40, 21), STEEL, 2)
c:fillMask(c:rect(34, 19, 40, 19), STEEL[1])
-- quirk: a weed caught in the loop
for _, p in ipairs{ {47,15,2}, {47,14,3}, {46,13,4}, {48,13,3}, {45,12,4}, {49,12,2} } do c:px(p[1], p[2], MOSS[p[3]]) end
c:px(44, 8, STEEL[1])
G.fin(c, "stirrup-hoe")
