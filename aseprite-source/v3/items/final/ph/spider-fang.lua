-- spider-fang (lean D2o_4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "spider-fang" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, ramp, R, o)
  local n = X.pillow(m, R)
  local v = X.light(n, o or { amb = 0.1, wrap = 0.25 })
  local idx = G.tone(c, m, v, ramp)
  return v, idx, n
end
local BONE = { "#2a1812", "#4a2a1c", "#6e4228", "#93612f", "#bc8a45", "#e3b86c" }
local VEN = { "#3f2a52", "#5c3b78", "#7e55a0", "#a47bc2", "#c9a2dc", "#eac8f0" }
-- venom gland at the base
local sac = c:ellipse(20, 16, 9, 8)
shade(sac, VEN, 7)
c:px(16, 12, VEN[6]) c:px(17, 12, VEN[6]) c:px(16, 13, VEN[5])
for _, p in ipairs{ {22,19,1}, {23,18,1}, {24,17,2}, {19,21,1}, {21,21,1} } do c:px(p[1], p[2], VEN[p[3]]) end
-- sinew cords
G.line(c, { {12,19}, {9,24}, {10,28} }, "#8a5a3a")
G.line(c, { {16,23}, {14,29}, {15,33} }, "#8a5a3a")
-- fang
local m, n, T, S = G.tube({ {24,18}, {38,17}, {49,31}, {42,51} }, function(t) return 4.6 * (1 - t) ^ 0.85 + 0.3 end)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
G.tone(c, m, v, BONE, { 0.2, 0.38, 0.55, 0.72, 0.88 })
m:each(function(x, y) local k = K(x, y)
  local t, s = T[k], S[k]
  if t > 0.55 then c:px(x, y, (t > 0.8) and BONE[1] or BONE[2]) end
  if t > 0.12 and t < 0.86 and abs(s - 0.25) < 0.1 then c:px(x, y, BONE[1]) end
  if t < 0.1 and abs(s) < 0.9 then c:px(x, y, VEN[2]) end
  if t > 0.15 and t < 0.6 and s < -0.55 and s > -0.8 then c:px(x, y, BONE[6]) end
end)
-- collar ring
c:fillMask(c:line({ {27,12}, {26,22} }, 1), BONE[1])
-- venom drop
c:fillMask(c:ellipse(42, 55, 2, 2), "#79d03a")
c:px(42, 53, "#79d03a") c:px(41, 54, "#d8f89a") c:px(43, 56, "#3e8a22")
G.fin(c, "spider-fang")
