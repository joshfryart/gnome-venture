-- sweet-potato (lean D2o_17)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function L(c, pts, hex) c:line(pts, 1):each(function(x, y) c:px(x, y, hex) end) end
local function shade(c, m, ramp, R, tok, bias, o)
  o = o or {} o.tok = tok o.bias = bias
  local n = X.pillow(m, R) local idx, v = G.toneN(c, m, n, ramp, o) return idx, v, n
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sweet-potato" }
local SK = { "#5a2a2a", "#8a4034", "#b5603c", "#d98650", "#eeab6c", "#f9cf92" }
local LF = { "#2b2540", "#3e3a62", "#4f6a58", "#6a9a58", "#8cc268", "#b4dc84" }
c:groundShadow(32, 56, 17, 2)
local m, n, T, S = G.tube({ {14, 36}, {26, 22}, {42, 46}, {55, 41} }, function(t)
  return max(0.9, 9.5 * sin(pi * (0.04 + 0.92 * t)) ^ 0.7)
end)
local tok = { r = { name = "tuber" } }
local bias = {}
m:each(function(x, y) local k = K(x, y)
  local s = S[k] or 0
  if abs(s - 0.35) < 0.07 and X.hash(x, y, 2) > 0.35 then bias[k] = -1 end
  if X.hash(x, y, 7) > 0.97 then bias[k] = -1 end
end)
local idx, v = G.toneN(c, m, n, SK, { tok = tok, bias = bias })
-- eyes: small dark dashes
for _, p in ipairs{ {28, 33}, {38, 40}, {33, 44}, {22, 33} } do
  if m:has(p[1], p[2]) then c:px(p[1], p[2], SK[1]) c:px(p[1] + 1, p[2], SK[2]) end
end
-- cool reflected light on lower rim
-- fibrous tail hairs
L(c, { {55, 41}, {57, 40}, {59, 41} }, SK[2])
L(c, { {54, 44}, {56, 46}, {57, 49} }, SK[2])
-- sprout (quirk): stem + two leaves at the thin head
local sm = G.tube({ {15, 34}, {13, 29}, {13, 25}, {15, 21} }, function(t) return 1.3 - 0.4 * t end)
G.toneN(c, sm, X.pillow(sm, 1.5), LF, { tok = { r = { name = "sprout" } } })
local l1, n1 = G.oval(10, 20, 4.5, 2.6, -0.9, 1)
shade(c, l1, LF, 3, { r = { name = "l1" } })
local l2, n2 = G.oval(20, 17, 5, 2.6, 0.5, 1)
shade(c, l2, LF, 3, { r = { name = "l2" } })
for i = -3, 3 do c:px(floor(10 + i * 0.5), floor(20 + i * -0.8), LF[6]) c:px(floor(20 + i * 0.9), floor(17 + i * 0.45), LF[6]) end
-- spec
c:px(27, 25, "#fff6f2") c:px(28, 25, "#fff6f2") c:px(26, 26, SK[6])
G.save(c, "sweet-potato")
