-- elder-pelt (lean W2_1)
-- Flat mossy-grey old hide with four legs, pale beard fringe, dark spine seam, hanging tail, red thread tie on a paw.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "elder-pelt" }
local FUR = { "#34362f", "#52564a", "#757b68", "#9aa086", "#bfc4a8", "#e3e5cd" }
local pelt = c:poly{ {24,12},{30,15},{36,14},{42,11},{44,18},{40,25},{49,28},{52,35},{45,37},{43,43},{47,51},{40,50},{34,45},{31,51},{26,49},{25,42},{19,45},{12,42},{16,35},{20,30},{13,23},{19,19} }
local tm, tn = G.tube({ {32,46},{32,50},{34,54},{33,57} }, function(t) return 2.2 * (1 - t) + 0.7 end)
tm:cut(pelt)
local n = X.pillow(pelt, 9)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
local bias = {}
pelt:each(function(x, y) local k = K(x, y)
  if X.hash(x, floor(y / 3), 5) > 0.72 then bias[k] = -1 end
  if abs(x - 31 - (y - 30) * 0.05) < 0.6 and y > 17 and y < 46 then bias[k] = -1 end
end)
G.tone(c, pelt, v, FUR, { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias)
G.tone(c, tm, X.light(tn, { amb = 0.12, wrap = 0.3 }), { "#26231f", "#3f3a30", "#5c5546", "#7d7562" }, { 0.3, 0.55, 0.8 })
-- fur strokes: short light flicks, pale beard along the top rim
pelt:each(function(x, y)
  if X.hash(x, y, 9) > 0.9 and v[K(x, y)] > 0.5 then c:px(x, y, FUR[5]) end
  if y < 20 and X.hash(x, y, 3) > 0.45 and v[K(x, y)] > 0.35 then c:px(x, y, FUR[6]) end
end)
for _, p in ipairs{ {21,22},{15,36},{44,12},{48,36},{43,48},{28,48} } do c:px(p[1], p[2], FUR[2]) end
-- red thread tie on the lower-left paw (quirk)
for _, p in ipairs{ {15,38},{16,39},{17,40},{16,38},{17,39} } do c:px(p[1], p[2], "#c8414a") end
c:px(15, 38, "#f07a6a") c:px(18, 41, "#8a2234")
-- tail tip
c:px(33, 56, "#16140f") c:px(33, 57, "#16140f")
G.fin(c, "elder-pelt")
