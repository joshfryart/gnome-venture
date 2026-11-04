-- sky-talon (lean W2_19)
-- Pale steel-blue raptor claw, leather-wrapped base, lavender feather hanging off the wrap (quirk).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sky-talon" }
local BL = { "#2f3f73", "#47629a", "#6b8fc4", "#98b9de", "#c4daf0", "#eef6fc" }
local LE = { "#5a3320", "#7d4a2a", "#a2693a", "#c58d4f", "#e2b472", "#f4d79c" }
local FE = { "#6a5a9a", "#8c7cc0", "#b0a2dc", "#d3c9f0" }
local m, n, T, S = G.tube({ {38,8}, {48,26}, {38,46}, {20,57} }, function(t) return 6.2 * (1 - t)^0.8 + 0.5 end)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
G.tone(c, m, v, BL)
local wrap = HP.mask()
m:each(function(x, y) local k = K(x, y)
  if T[k] < 0.2 then wrap:set(x, y) end
  if T[k] > 0.24 and T[k] < 0.92 and S[k] > -0.62 and S[k] < -0.36 then c:px(x, y, BL[5]) end
  if T[k] > 0.3 and S[k] > 0.55 then c:px(x, y, BL[1]) end
end)
G.tone(c, wrap, v, LE)
wrap:each(function(x, y) local k = K(x, y)
  if (x + 2 * y) % 5 == 0 then c:px(x, y, LE[2]) elseif (x + 2 * y) % 5 == 1 then c:px(x, y, LE[5]) end
  if T[k] > 0.17 then c:px(x, y, LE[1]) end
end)
c:px(41, 12, "#fffaf0") c:px(42, 13, "#fffaf0")
-- feather
local fm, fn, FT, FS = G.tube({ {36,12}, {26,14}, {24,26}, {29,36} }, function(t) return 2.8 * math.sin(math.pi * min(1, t * 0.9 + 0.1)) ^ 0.7 + 0.4 end)
fm:cut(m)
G.tone(c, fm, X.light(fn, { amb = 0.2, wrap = 0.3 }), FE, { 0.3, 0.55, 0.8 })
fm:each(function(x, y) local k = K(x, y) if abs(FS[k]) < 0.14 then c:px(x, y, FE[4]) end end)
G.fin(c, "sky-talon")
