-- stolen-bauble (lean D2o_13)
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
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stolen-bauble" }
c:groundShadow(32, 53, 11, 2)
local ball = c:ellipse(32, 38, 14, 14)
local n = X.pillow(ball, 14)
local v = X.light(n, { amb = 0.08, wrap = 0.2 })
G.tone(c, ball, v, RED, nil, nil, nil)
ball:each(function(x, y) local k = K(x, y)
  local d = (y - 38) - 0.55 * (x - 32) - 3 * sin((x - 32) * 0.45)
  if abs(d) < 2.2 then c:px(x, y, pick(GOLD, v[k])) end
  if abs(d - 6) < 0.6 and (x % 3 == 0) then c:px(x, y, GOLD[5]) end
end)
-- glass: spec arc + reflected light
c:fillMask(c:rect(23, 29, 25, 30), "#fff6f2") c:px(26, 28, "#fff6f2") c:px(22, 31, RED[6]) c:px(23, 33, RED[6])
for y = 46, 49 do c:px(40 - (y - 46), y, "#e89a8a") end
-- cap, ring, torn thread
paint(c:rect(28, 21, 36, 24), GOLD, 2)
c:fillMask(c:rect(28, 23, 36, 23), GOLD[1])
local ring = c:ellipse(32, 17, 4, 4):cut(c:ellipse(32, 17, 2, 2))
paint(ring, GOLD, 2)
for _, p in ipairs{ {32,13}, {31,12}, {31,11}, {32,10}, {33,9}, {31,9}, {34,8} } do c:px(p[1], p[2], WOOD[4]) end
-- quirk: a sticky thumbprint smudge
for _, p in ipairs{ {38,36}, {39,35}, {40,36}, {39,37}, {40,38}, {38,39}, {41,34} } do c:px(p[1], p[2], RED[5]) end
G.fin(c, "stolen-bauble")
