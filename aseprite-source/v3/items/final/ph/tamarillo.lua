-- tamarillo (lean D2o_18)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local NAME = "tamarillo"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function sh(m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias)
  return n, v
end
local function tub(pts, wfn, ramp, o) o = o or {}
  local m, n, T, S = G.tube(pts, wfn)
  G.tone(c, m, X.light(n, { amb = o.amb or 0.12, wrap = o.wrap or 0.3 }), ramp, o.cuts)
  return m, T, S
end
local RED = { "#3d1230", "#6b1a3e", "#9a2748", "#c33d52", "#e0645f", "#f29a82" }
local FL = { "#7a2218", "#b03c1c", "#d9602a", "#f08a3a", "#f8b458", "#fcd88a" }
local GR = { "#1e3a2a", "#2f5a38", "#4a7e48", "#7aa860", "#a8c880" }
c:groundShadow(34, 54, 17, 2.5)
-- stalk
tub({ {23, 24}, {23, 18}, {27, 14}, {31, 12} }, function(t) return 1.6 - 0.5 * t end, GR)
-- whole fruit, egg shaped, tilted
local fr = G.rell(25, 37, 0.15, 1, 15, 11.5)
local n, v = sh(fr, RED, 13, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.87 } })
-- dark vertical stripes (tamarillo ribbing)
fr:each(function(x, y)
  local a = (x - 25) / 11.5
  for _, s in ipairs{ -0.62, -0.1, 0.45 } do
    if abs(a - s - 0.12 * ((y - 37) / 15) ^ 2 * (a > 0 and 1 or -1)) < 0.045 and y > 27 and y < 49 and v[K(x, y)] < 0.8 then c:px(x, y, RED[2]) end
  end
end)
-- waxy sheen specks
fr:copy():shrink(2):each(function(x, y) if v[K(x, y)] > 0.72 and X.hash(x, y, 5) > 0.9 then c:px(x, y, RED[6]) end end)
c:px(18, 31, "#fff0ea") c:px(19, 31, "#fff0ea") c:px(18, 32, RED[6]) c:px(20, 30, RED[6])
-- calyx: little green star
for _, p in ipairs{ {21, 24}, {22, 24}, {23, 25}, {24, 24}, {25, 24}, {22, 26}, {24, 26}, {20, 25}, {26, 25} } do c:px(p[1], p[2], GR[3]) end
c:px(23, 24, GR[5]) c:px(22, 25, GR[2]) c:px(24, 25, GR[2]) c:px(23, 26, GR[1])
-- cut half in front
local half = G.rell(42, 44, 0.3, 0.95, 9, 8.2)
sh(half, RED, 7)
local fle = half:copy():shrink(1)
local nf = X.pillow(fle, 14)
G.tone(c, fle, X.light(nf, { amb = 0.55, wrap = 0.6 }), FL, { 0.15, 0.3, 0.45, 0.62, 0.8 })
c:fillMask(G.rell(42, 44, 0.3, 0.95, 2.6, 2.2), FL[6])
for i = 0, 5 do
  local a = i * pi / 3 + 0.4
  local sx, sy = 42 + cos(a) * 4.7, 44 + sin(a) * 4.9
  c:fillMask(G.rell(sx, sy, cos(a), sin(a), 1.7, 1.0), "#4a1a2a")
  c:px(floor(sx - 0.3), floor(sy - 0.5), "#c06070")
end
c:px(37, 38, "#fff0d0") c:px(38, 37, FL[6])
-- quirk: a bite of juice running over the rind
c:px(48, 50, FL[4]) c:px(48, 51, FL[5])
G.fin(c, NAME)
