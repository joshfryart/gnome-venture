-- thorn-fang (lean W2_33)
-- A long curved bone fang hung from a leather-wrapped base and cord loop; ringed growth lines, hollow tip chip,
-- and a small green thorn stuck in the flank (quirk).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "thorn-fang" }
local floor, abs, sin, max, min = math.floor, math.abs, math.sin, math.max, math.min
local BONE = { "#5a4668", "#8a7088", "#b99d95", "#dcc4a6", "#f2e2c0", "#fff8e2" }
local LEATH = { "#2e1a16", "#4c2a20", "#6e4228", "#926038", "#b88450" }
local GREEN = { "#1f4a2e", "#2f6e3a", "#4a9448", "#7cbf5c" }
c:groundShadow(35, 58, 9, 2)
local fm, fn, T, S = G.tube({ { 22, 14 }, { 47, 10 }, { 52, 38 }, { 31, 55 } },
  function(t) return 5.6 * (1 - t) ^ 0.8 + 0.4 end)
local v = X.light(fn, { amb = 0.1, wrap = 0.25 })
G.tone(c, fm, v, BONE, { 0.2, 0.38, 0.55, 0.7, 0.86 })
fm:each(function(x, y) local k = K(x, y)
  local t = T[k]
  if t > 0.2 and (t * 15) % 1 < 0.1 and abs(S[k]) < 0.8 then c:px(x, y, S[k] <= 0 and BONE[3] or BONE[2]) end
  if S[k] < -0.4 and S[k] > -0.65 and t > 0.25 and t < 0.8 then c:px(x, y, BONE[6]) end   -- streak
  if S[k] > 0.8 then c:px(x, y, BONE[1]) end end)
-- chipped tip
c:px(32, 54, BONE[1]) c:px(33, 53, BONE[2])
-- leather wrap on the base
local wrap = HP.mask()
fm:each(function(x, y) if T[K(x, y)] < 0.16 then wrap:set(x, y) end end)
G.tone(c, wrap, v, LEATH, { 0.2, 0.4, 0.58, 0.76, 0.9 })
wrap:each(function(x, y) if (x + y) % 4 == 0 then c:px(x, y, LEATH[1]) end end)
for y = 7, 12 do end
-- cord loop
local ring = c:ellipse(18, 11, 5, 5):cut(c:ellipse(18, 11, 3, 3))
ring:each(function(x, y) c:px(x, y, (x + y) % 3 == 0 and "#e3c88c" or (x < 18 and "#c9a266" or "#8e6a3c")) end)
-- thorn stuck in the flank
local th = c:poly{ { 41, 22 }, { 47, 19 }, { 43, 26 } }
G.tone(c, th, (function() local t = {} th:each(function(x, y) t[K(x, y)] = max(0, min(1, 0.9 - (x - 41) * 0.1 - (y - 19) * 0.05)) end) return t end)(), GREEN, { 0.25, 0.5, 0.75 })
c:px(46, 19, GREEN[4])
G.fin(c, "thorn-fang")
