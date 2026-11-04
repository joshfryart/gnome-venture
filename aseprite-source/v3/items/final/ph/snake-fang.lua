-- snake-fang (lean W2_19)
-- Ivory curved fang, magenta gum cap on top, green venom groove, hanging venom drop (quirk).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "snake-fang" }
local IV = { "#7a6a7e", "#a89aa0", "#cfc2b8", "#ebe0cc", "#f8f0de", "#fffcf0" }
local GM = { "#5a1f3e", "#80284e", "#a63a5e", "#c9576c", "#e58588", "#f7b4a8" }
local GR = { "#1f5a3a", "#2f8a45", "#58b84e", "#92dc6c", "#d0f59a" }
local m, n, T, S = G.tube({ {20,10}, {20,30}, {28,46}, {46,52} }, function(t) return 5.6 * (1 - t)^0.75 + 0.5 end)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
G.tone(c, m, v, IV)
m:each(function(x, y) local k = K(x, y)
  if T[k] > 0.3 and T[k] < 0.88 and abs(S[k] - 0.15) < 0.13 then c:px(x, y, GR[T[k] > 0.6 and 3 or 2]) end
  if T[k] > 0.12 and T[k] < 0.7 and S[k] > -0.6 and S[k] < -0.38 then c:px(x, y, IV[6]) end
end)
-- gum cap
local cap = G.rell(20, 9, 1, 0, 10, 4.6)
local cn = X.pillow(cap, 4)
G.tone(c, cap, X.light(cn, { amb = 0.12, wrap = 0.25 }), GM)
c:px(15, 7, GM[6]) c:px(16, 7, GM[6]) c:px(15, 8, GM[5])
c:fillMask(c:rect(14, 13, 26, 13), GM[1])
-- venom drop
local d = G.rell(47, 58, 0, 1, 3, 2.2)
G.tone(c, d, X.light(X.pillow(d, 2.5), { amb = 0.2, wrap = 0.3 }), GR, { 0.3, 0.5, 0.7, 0.88 })
c:px(46, 56, GR[5]) c:px(47, 54, GR[3]) c:px(47, 55, GR[3])
G.fin(c, "snake-fang")
