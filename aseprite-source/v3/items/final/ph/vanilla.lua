-- vanilla (lean D3o_8)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan

local c = HP.canvas{ w=64, h=64, scale=1, name="vanilla" }
local POD = { "#1e120f", "#33201a", "#4d3025", "#6e4630", "#966142", "#c18a5c" }
local TW = { "#6b5030", "#9a7a46", "#c9a965", "#ecd698" }
local PET = { "#b9a8b8", "#dcd0d0", "#f4ecdc", "#fffaf0" }
c:groundShadow(34, 57, 15, 2)
local pods = {
  { {12,54},{16,38},{24,24},{40,10}, 2.2 },
  { {20,56},{28,42},{36,32},{52,20}, 2.0 },
  { {26,57},{36,48},{46,40},{54,36}, 1.8 },
}
local keep = {}
for i, P in ipairs(pods) do
  local base = P[5]
  local m, nn, T, S = G.tube({P[1],P[2],P[3],P[4]}, function(t) return base * (0.45 + 0.55 * sin(min(1, t * 1.15 + 0.05) * pi)^0.5) end)
  local v = X.light(nn, { amb = 0.06, wrap = 0.25 })
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.18 then bias[k] = -1 end
    if X.hash(x, y, 3 + i) > 0.9 and abs(S[k]) < 0.8 then bias[k] = -1 end
  end)
  G.tone(c, m, v, POD, { 0.2, 0.38, 0.54, 0.7, 0.88 }, bias)
  -- frosty vanilla crystals
  m:each(function(x, y) if v[K(x, y)] > 0.55 and X.hash(x, y, 20 + i) > 0.9 then c:px(x, y, "#f3e6c8") end end)
  -- curled tip
  keep[i] = P
end
-- curl at tip of pod 1
G.line(c, { {40,10},{42,9},{44,10},{44,12} }, POD[3])
c:px(43, 9, POD[5])
-- twine tie around the bundle
local TX, TY = 27, 38
for _, p in ipairs{ {22,42},{25,41},{28,39},{31,37},{34,35} } do
  c:px(p[1], p[2], TW[3]) c:px(p[1], p[2]+1, TW[2]) c:px(p[1]+1, p[2]+1, TW[1])
end
-- bow
G.line(c, { {28,39},{25,35},{22,36},{25,39} }, TW[3])
G.line(c, { {28,39},{32,41},{35,44},{31,44} }, TW[3])
c:px(28, 39, TW[4]) c:px(25, 36, TW[4])
-- quirk: tiny orchid flower tucked in the tie
local fx, fy = 29, 36
for _, p in ipairs{ {0,-2},{2,-1},{1,1},{-1,1},{-2,-1} } do
  c:fillMask(c:ellipse(fx + p[1], fy + p[2], 1, 1), PET[3])
  c:px(fx + p[1], fy + p[2], PET[4])
end
c:px(fx, fy, "#e8c25a")
c:px(fx - 1, fy - 3, PET[1]) c:px(fx + 3, fy - 1, PET[1])
G.fin(c, "vanilla")
