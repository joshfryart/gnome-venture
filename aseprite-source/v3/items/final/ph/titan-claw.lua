-- titan-claw (lean P1b_O20)
-- quirk: a chipped nick on the inner curve and a brass hanging ring.
local NAME = "titan-claw"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local hash = X.hash
local function tk(n) return { r = { name = n } } end
local function clamp(i, n) return max(1, min(n, i)) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local IV = { "#4a3a58", "#7c6a80", "#aa9aa2", "#d2c6bc", "#ece2cc", "#fff6e2" }
local HORN = { "#1e1228", "#3c2040", "#603450", "#885064", "#b47a78", "#dca894" }
local LE = { "#2a1618", "#4c2a22", "#704630", "#966642", "#be8c54", "#e2b26c" }
local CORD = { "#5a1428", "#9c2236", "#d64448", "#f87c62" }
local GOLD = { "#5a3a18", "#8c5c20", "#c28c2e", "#eab845", "#ffdc70" }
c:groundShadow(36, 58, 15, 2)
local m, n, T, S = G.tube({ { 17, 14 }, { 8, 38 }, { 32, 58 }, { 54, 48 } }, function(t) return 7.6 * (1 - t) ^ 0.85 + 0.6 end)
-- chipped nick
m:each(function(x, y) local k = K(x, y) if T[k] > 0.5 and T[k] < 0.56 and S[k] < -0.5 then m:cut(HP.mask():set(x, y)) end end)
local v = X.light(n, { amb = 0.08, wrap = 0.3 })
local body, tip, wrap = HP.mask(), HP.mask(), HP.mask()
m:each(function(x, y)
  local t = T[K(x, y)]
  if t < 0.2 then wrap:set(x, y) elseif t > 0.7 + 0.05 * hash(x, y, 2) then tip:set(x, y) else body:set(x, y) end
end)
local bias = {}
body:each(function(x, y) local t = T[K(x, y)] if (t * 11) % 1 < 0.13 then bias[K(x, y)] = -1 end end)
X.tone(c, body, v, IV, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, bias = bias, tok = tk("claw") })
X.tone(c, tip, v, HORN, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, tok = tk("tip") })
X.tone(c, wrap, v, LE, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, tok = tk("wrap") })
wrap:each(function(x, y) if (x + y) % 5 < 2 then c:px(x, y, v[K(x, y)] > 0.55 and CORD[4] or (v[K(x, y)] > 0.3 and CORD[3] or CORD[1])) end end)
-- spec streak along lit side
body:each(function(x, y) local k = K(x, y) if S[k] < -0.4 and S[k] > -0.65 and T[k] > 0.24 and hash(x, y, 5) > 0.12 then c:px(x, y, IV[6]) end end)
tip:each(function(x, y) local k = K(x, y) if S[k] < -0.35 and S[k] > -0.7 and hash(x, y, 6) > 0.4 then c:px(x, y, HORN[6]) end end)
-- ring
local ring = HP.mask():add(c:ellipse(16, 9, 4, 4)):cut(c:ellipse(16, 9, 1, 1))
X.tone(c, ring, X.light(X.pillow(ring, 2), { amb = 0.2, wrap = 0.4 }), GOLD, { cuts = { 0.2, 0.4, 0.6, 0.8 }, tok = tk("ring") })
c:px(14, 7, GOLD[5])
G.save(c, NAME)
