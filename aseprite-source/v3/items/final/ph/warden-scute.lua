-- warden-scute (lean D3o_9)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w=64, h=64, scale=1, name="warden-scute" }
local BONE = { "#3a3040", "#5d5062", "#8a7c84", "#b8aaa4", "#ddd2c4", "#f6efe0" }
local TEAL = { "#0f3a44", "#14606a", "#1f94909", "#3cc7b4", "#8ae8d0", "#d6fff0" }
TEAL[3] = "#1f9490"
c:groundShadow(32, 54, 18, 3)
local P = { {32,8},{48,15},{53,31},{46,47},{32,53},{18,47},{11,31},{16,15} }
local pm = c:poly(P)
-- rear rim: darker thick underside
local under = pm:copy():shift(2, 3):cut(pm)
G.tone(c, under, X.light(X.pillow(under, 2), {amb=0.1, wrap=0.2}), BONE, {0.5,0.7,0.85,0.95,0.99})
local n = X.pillow(pm, 12)
local v = X.light(n, {amb=0.1, wrap=0.2})
local bias = {}
pm:each(function(x, y) local k = K(x, y)
  local d = sqrt((x - 32)^2 + ((y - 31) * 1.1)^2)
  if d % 6.5 < 1 and d > 6 and X.hash(x, y, 4) > 0.15 then bias[k] = -1 end
end)
G.tone(c, pm, v, BONE, nil, bias)
-- radial groove cracks
for _, a in ipairs{ 0.5, 2.0, 3.6, 5.1 } do
  local pts = {}
  for r = 8, 19, 1 do pts[#pts+1] = { floor(32 + cos(a)*r + 0.5), floor(31 + sin(a)*r*0.95 + 0.5) } end
  pm:copy():shrink(1)
  for _, p in ipairs(pts) do if pm:copy():shrink(1):has(p[1], p[2]) then c:px(p[1], p[2], BONE[2]) end end
end
-- sculk inlay: glowing teal diamond boss (quirk)
local boss = c:poly{ {32,23},{39,31},{32,39},{25,31} }
G.tone(c, boss, X.light(X.pillow(boss, 6), {amb=0.2, wrap=0.4}), TEAL)
G.line(c, { {32,26},{32,36} }, TEAL[6]) G.line(c, { {28,31},{36,31} }, TEAL[5])
c:px(32, 31, TEAL[6])
-- two glow motes
c:px(22, 22, TEAL[5]) c:px(44, 40, TEAL[4])
-- spec on rim upper-left
G.line(c, { {15,17},{22,12} }, BONE[6])
G.fin(c, "warden-scute")
