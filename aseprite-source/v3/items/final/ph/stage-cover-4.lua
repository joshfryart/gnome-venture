-- stage-cover-4 (lean W2_22)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-cover-4" }
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
c:groundShadow(32, 54, 22, 3)
soil(32, 48, 23, 7, 3)
-- lumpy ground-cover cushion: overlapping leafy domes
local doms = { {18,40,9,8}, {46,40,9,8}, {26,36,10,9}, {39,36,10,9}, {32,43,10,7} }
for _, d in ipairs(doms) do
  local m = c:ellipse(d[1], d[2], d[3], d[4])
  local n = X.pillow(m, 6)
  G.tone(c, m, X.light(n, { amb = 0.08, wrap = 0.2 }), LEAF, { 0.2, 0.38, 0.55, 0.72, 0.88 })
  m:each(function(x, y) local h = X.hash(x, y, d[1])
    if h > 0.9 then c:px(x, y, LEAF[6]) elseif h < 0.1 then c:px(x, y, LEAF[2]) end end)
  c:fillMask(c:ellipse(d[1], d[2] + d[4] - 1, d[3] - 1, 1), LEAF[1])
end
-- tiny pink blossoms, one red berry (quirk)
for _, f in ipairs{ {22,32},{33,28},{42,31},{28,39},{47,40},{15,38} } do
  c:px(f[1], f[2], "#fff0f4") c:px(f[1]-1, f[2], "#f07aa0") c:px(f[1]+1, f[2], "#f07aa0")
  c:px(f[1], f[2]-1, "#f07aa0") c:px(f[1], f[2]+1, "#c4466c")
end
c:fillMask(c:ellipse(38, 45, 2, 2), "#d9344a") c:px(37, 44, "#ff9a9a") c:px(39, 46, "#8e1f3c")
G.fin(c, "stage-cover-4")
