-- stage-fruit-1 (lean W2_22)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-fruit-1" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local SOIL = { "#2e1e22", "#4a2e2c", "#6b4430", "#8c5e3a", "#ad7d4b", "#cfa064" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local function soil(cx, cy, rx, ry, seed)
  local m = c:ellipse(cx, cy, rx, ry)
  local n = X.pillow(m, 5)
  G.tone(c, m, X.light(n, { amb = 0.1, wrap = 0.25 }), SOIL, { 0.2, 0.38, 0.55, 0.72, 0.88 })
  m:each(function(x, y) local h = X.hash(x, y, seed)
    if h > 0.93 then c:px(x, y, SOIL[6]) elseif h < 0.07 then c:px(x, y, SOIL[1]) end end)
  return m
end
c:groundShadow(32, 54, 21, 3)
soil(32, 49, 21, 6, 8)
-- stem
local sm, sn = G.tube({ {32,48}, {32,42}, {33,36}, {32,29} }, function(t) return 1.8 - 0.5 * t end)
G.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), { "#3b6449", "#5b8d5a", "#88b46e", "#b9d793" }, { 0.3, 0.55, 0.8 })
-- two fat seed leaves (cotyledons) drooping out, left plain oval, right with seed-coat hat
local function cot(cx, cy, ang, rx, ry)
  local m = HP.mask()
  for t = -1, 1, 0.05 do local x, y = cx + cos(ang) * t * rx, cy + sin(ang) * t * rx
    local h = ry * sqrt(max(0, 1 - t * t)) 
    for dy = -floor(h), floor(h) do m:set(floor(x + 0.5), floor(y + dy + 0.5)) end end
  local n = X.pillow(m, 3.5)
  G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.25 }), LEAF, { 0.2, 0.38, 0.55, 0.72, 0.88 })
  return m
end
cot(21, 34, -0.5, 10, 5)
cot(44, 33, 0.5, 10, 5)
for i = 0, 8 do c:px(14 + i, 38 - floor(i * 0.5), LEAF[5]) end
for i = 0, 8 do c:px(48 - i, 37 - floor(i * 0.5), LEAF[5]) end
-- true first leaf bud on top
local bm, bn = G.tube({ {32,29}, {32,26}, {32,24}, {33,21} }, function(t) return 1.5 * (1 - t) + 0.6 end)
G.tone(c, bm, X.light(bn, {}), LEAF, { 0.2, 0.38, 0.55, 0.72, 0.88 })
-- quirk: seed-coat cap perched on right cotyledon tip
local hat = c:ellipse(53, 29, 3, 2)
G.tone(c, hat, X.light(X.pillow(hat, 2), {}), { "#6b4430", "#8c5e3a", "#c9a15a", "#e8cf8e", "#f6e8bd", "#fffaf0" }, { 0.25, 0.45, 0.65, 0.8, 0.92 })
c:px(52, 28, "#fffaf0")
G.fin(c, "stage-fruit-1")
