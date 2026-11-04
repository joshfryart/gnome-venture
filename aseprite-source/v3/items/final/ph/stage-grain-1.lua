-- stage-grain-1 (lean W2_22)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stage-grain-1" }
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
soil(32, 49, 22, 6, 5)
-- furrow line
for x = 14, 50 do c:px(x, 50 + floor(sin(x * 0.5) + 0.5), SOIL[2]) end
-- grass blades: curved thin blades fanning from the soil
local blades = {
  { {30,48}, {26,40}, {18,32}, 2.2 }, { {32,48}, {31,36}, {31,24}, 2.0 },
  { {34,48}, {38,40}, {47,32}, 2.2 }, { {31,48}, {24,44}, {14,40}, 1.6 }, { {33,48}, {40,44}, {50,41}, 1.6 } }
for _, b in ipairs(blades) do
  local m, n = G.tube({ b[1], {(b[1][1]+b[2][1])/2, (b[1][2]+b[2][2])/2 - 1}, b[2], b[3] }, function(t) return b[4] * (1 - t) ^ 0.7 + 0.3 end)
  G.tone(c, m, X.light(n, { amb = 0.15, wrap = 0.3 }), LEAF, { 0.2, 0.38, 0.55, 0.72, 0.88 })
end
-- quirk: grain kernel half-buried, still wearing its husk tip
local k = c:ellipse(40, 49, 3, 2)
G.tone(c, k, X.light(X.pillow(k, 2), {}), { "#6b4a1e", "#9a7430", "#cfa24a", "#e8c46a", "#f6de94", "#fff6c8" }, { 0.25, 0.45, 0.65, 0.8, 0.92 })
c:px(39, 48, "#fff6c8") c:px(43, 48, "#6b4a1e")
G.fin(c, "stage-grain-1")
