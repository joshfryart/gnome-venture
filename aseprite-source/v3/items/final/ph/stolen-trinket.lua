-- stolen-trinket (lean D2o_13)
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
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stolen-trinket" }
-- chain
local cm, cn, T = G.tube({ {30,13}, {38,5}, {52,9}, {54,25} }, function(t) return 1.0 end)
cm:each(function(x, y) c:px(x, y, (floor(T[K(x, y)] * 40) % 2 == 0) and GOLD[4] or GOLD[2]) end)
paint(c:ellipse(54, 28, 3, 3), { "#10424a", "#1c6a70", "#2c9a90", "#5cc8a8", "#a8ecc8", "#e8fff0" }, 3)
-- case
local case = c:ellipse(30, 38, 15, 15)
paint(case, GOLD, 15)
local face = c:ellipse(30, 38, 11, 11)
paint(face, { "#9a8c92", "#c4b8b4", "#e0d6cc", "#f2eadc", "#fbf5e8", "#fff6f2" }, 11, { amb = 0.4, wrap = 0.5 })
c:fillMask(face:copy():shrink(10):grow(0), "#fbf5e8")
for i = 0, 11 do local a = i * pi / 6
  local r1, r2 = (i % 3 == 0) and 7.5 or 9, 10
  G.line(c, { {floor(30 + sin(a) * r1 + 0.5), floor(38 - cos(a) * r1 + 0.5)}, {floor(30 + sin(a) * r2 + 0.5), floor(38 - cos(a) * r2 + 0.5)} }, "#4a3640") end
G.line(c, { {30,38}, {30,31} }, "#2b1c26") G.line(c, { {30,38}, {35,41} }, "#7a1c34")
c:px(30, 38, GOLD[5])
-- crown + bow
paint(c:rect(27, 21, 33, 24), GOLD, 2)
local bow = c:ellipse(30, 17, 4, 4):cut(c:ellipse(30, 17, 2, 2))
paint(bow, GOLD, 2)
-- glint on bezel + quirk: cracked glass
c:fillMask(c:rect(19, 29, 21, 29), GOLD[6]) c:px(18, 31, GOLD[6]) c:px(22, 28, GOLD[6])
for _, p in ipairs{ {36,30}, {35,32}, {36,34}, {34,35}, {35,37} } do c:px(p[1], p[2], "#fff6f2") end
G.fin(c, "stolen-trinket")
