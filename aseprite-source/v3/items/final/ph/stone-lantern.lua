-- stone-lantern (lean D2o_13)
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
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stone-lantern" }
c:groundShadow(32, 53, 17, 2)
paint(c:rect(19, 48, 45, 52), STONE, 3)
paint(c:rect(23, 44, 41, 47), STONE, 2)
paint(c:rect(28, 33, 36, 43), STONE, 4)
paint(c:ellipse(32, 39, 7, 3), STONE, 3)
paint(c:rect(22, 21, 42, 32), STONE, 5)
-- glowing window with cross bar
local win = c:rect(26, 23, 38, 30)
local GL = { "#a8440c", "#d8701c", "#f4a028", "#fcc83c", "#ffe27a", "#fff6c0" }
win:each(function(x, y) c:px(x, y, GL[min(6, 2 + floor((x - 26) / 3.5) % 2 + (y < 26 and 1 or 0) + ((x + y) % 5 == 0 and 1 or 0))]) end)
c:fillMask(c:rect(31, 23, 33, 30), STONE[1]) c:fillMask(c:rect(26, 26, 38, 26), STONE[1])
c:px(28, 24, GL[6]) c:px(29, 24, GL[6])
-- roof
local roof = c:poly{ {12,22}, {52,22}, {44,14}, {20,14} }
local v = paint(roof, STONE, 5)
for x = 14, 50, 6 do G.line(c, { {x, 22}, {32 + (x - 32) * 0.55, 15} }, STONE[2]) end
c:fillMask(c:rect(12, 22, 52, 22), STONE[1])
paint(c:rect(26, 10, 38, 13), STONE, 2)
paint(c:ellipse(32, 8, 3, 3), STONE, 3)
c:px(32, 4, STONE[4]) c:px(32, 5, STONE[3])
-- quirk: moss + a firefly
for _, p in ipairs{ {14,22,3},{15,22,4},{16,22,3},{16,21,3},{17,21,2},{15,21,2},{18,20,3},{19,20,2},{21,19,3},{20,22,2},{13,22,2} } do c:px(p[1], p[2], MOSS[p[3]]) end
for _, p in ipairs{ {27,42,2},{28,41,3},{29,43,2} } do c:px(p[1], p[2], MOSS[p[3]]) end
c:px(50, 30, "#fff08a") c:px(49, 30, "#d8c048") c:px(51, 30, "#d8c048")
G.fin(c, "stone-lantern")
