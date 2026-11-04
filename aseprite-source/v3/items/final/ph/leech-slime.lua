-- leech-slime (lean W2_7)
-- A ringed leech arching out of a glossy slime puddle, sucker mouth and eyes up front, a slime strand dripping from its belly (quirk).
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "leech-slime" }
local BODY = { "#1d3320", "#2c4d2a", "#456f2f", "#6c9a3a", "#9cc653", "#d0e87e" }
local SLIM = { "#1f6a52", "#2e9466", "#4fbf78", "#86e08c", "#c4f7b0" }
-- puddle
local pm, pn = G.oval(32, 51, 25, 6.5, 0, 0.6)
G.toneN(c, pm, pn, SLIM, { amb = 0.2, wrap = 0.4 })
pm:each(function(x, y) if X.hash(x, y, 9) > 0.93 then c:px(x, y, SLIM[5]) end end)
for _, p in ipairs{ {12,50},{13,50},{14,50} } do c:px(p[1], p[2], SLIM[5]) end
-- drip strand + bulb
local ds, dn = G.tube({ {26, 26}, {26, 32}, {27, 40}, {27, 48} }, function(t) return 1.1 + 0.4 * t end)
G.toneN(c, ds, dn, SLIM)
local db, dbn = G.oval(27, 41, 2.2, 2.6, 0, 1)
G.toneN(c, db, dbn, SLIM)
c:px(26, 40, SLIM[5])
-- leech body arch
local bm, bn, T, S = G.tube({ {10, 49}, {8, 16}, {44, 8}, {47, 36} }, function(t)
  return 1.2 + 4.2 * sin(min(1, t * 1.15) * pi) ^ 0.7 + 0.8 * t
end)
local v = X.light(bn, { amb = 0.1, wrap = 0.25 })
local bias = {}
bm:each(function(x, y) local k = K(x, y)
  local ring = floor(T[k] * 30)
  if ring % 2 == 0 then bias[k] = -1 end
end)
X.tone(c, bm, v, BODY, { cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias = bias })
-- dorsal stripe (light side) and belly line
bm:each(function(x, y) local k = K(x, y)
  if abs(S[k] + 0.3) < 0.13 and T[k] > 0.08 and T[k] < 0.92 and floor(T[k] * 30) % 2 == 1 then c:px(x, y, "#e0a040") end
  if S[k] > 0.8 then c:px(x, y, BODY[1]) end
end)
-- spec glints on the arch
c:px(18, 14, "#f6ffd8") c:px(19, 13, "#f6ffd8") c:px(20, 12, BODY[6]) c:px(21, 12, BODY[6])
-- head: sucker mouth + eyes at the right end
for _, p in ipairs{ {46,40},{47,40},{48,40},{45,41},{49,41},{46,42},{47,42},{48,42} } do c:px(p[1], p[2], "#c8506a") end
c:px(47, 41, "#4a0f1f")
c:px(46, 33, "#fff6e0") c:px(46, 34, "#1a1018") c:px(49, 33, "#fff6e0") c:px(49, 34, "#1a1018")
-- tail sucker
c:px(9, 48, BODY[1]) c:px(10, 48, BODY[2])
G.save(c, "leech-slime")
