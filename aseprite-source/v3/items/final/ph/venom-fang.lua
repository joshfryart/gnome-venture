-- venom-fang (lean D3o_8)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan

local c = HP.canvas{ w=64, h=64, scale=1, name="venom-fang" }
local IV = { "#6a5a5c", "#988a82", "#c4b8a8", "#e6dcc8", "#f8f0de", "#fffdf2" }
local GUM = { "#6a2740", "#9a3c58", "#c85e74", "#e8909a" }
local VEN = { "#1c5a2a", "#2f8d34", "#6bc83e", "#b8f06a" }
c:groundShadow(36, 57, 14, 2)
local pts = { {16,13},{34,10},{44,28},{46,50} }
local m, nn, T, S = G.tube(pts, function(t) return 5.4 * (1 - t)^0.85 + 0.5 end)
local v = X.light(nn, { amb = 0.1, wrap = 0.3 })
local bias = {}
m:each(function(x, y) local k = K(x, y)
  if T[k] < 0.12 then bias[k] = -1 end
  if T[k] > 0.2 and T[k] < 0.9 and S[k] > 0.5 and S[k] < 0.75 then bias[k] = -1 end
end)
G.tone(c, m, v, IV, { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias)
-- enamel ridges (long streaks)
m:each(function(x, y) local k = K(x, y)
  if S[k] < -0.4 and S[k] > -0.6 and T[k] > 0.15 and T[k] < 0.7 then c:px(x, y, IV[6]) end
end)
-- venom groove, green, down the inner (lower-left) side to the tip
m:each(function(x, y) local k = K(x, y)
  if T[k] > 0.28 and T[k] < 0.97 and S[k] > 0.12 and S[k] < 0.4 - T[k] * 0.2 then
    c:px(x, y, T[k] > 0.7 and VEN[3] or VEN[2])
  end
end)
-- gum socket (quirk free: gum and root)
local gum = c:ellipse(14, 13, 7, 8):add(c:ellipse(20, 8, 5, 4))
gum:cut(c:ellipse(25, 14, 3, 3))
G.tone(c, gum, X.light(X.pillow(gum, 6), { amb = 0.1, wrap = 0.3 }), GUM, { 0.3, 0.55, 0.8 })
c:px(11, 10, "#ffc8c8") c:px(12, 10, "#ffc8c8")
-- quirk: venom drop clinging to the tip + a tiny crack in the enamel
local drop = c:ellipse(46, 56, 2, 2):add(c:rect(46, 53, 46, 54))
G.tone(c, drop, X.light(X.pillow(drop, 3), { amb = 0.1, wrap = 0.3 }), VEN, { 0.3, 0.55, 0.8 })
c:px(45, 55, VEN[4]) c:px(45, 56, "#e8ffb0")
G.line(c, { {38,16},{40,19},{39,21} }, IV[1])
c:px(21, 12, IV[6]) c:px(22, 12, IV[6]) c:px(23, 12, IV[5])
G.fin(c, "venom-fang")
