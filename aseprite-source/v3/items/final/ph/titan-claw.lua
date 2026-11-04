-- titan-claw (lean W2_34)
-- Big hooked talon hanging point-down: ridged horn, dark keratin tip, leather-bound root with a cord loop; chipped notch quirk.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "titan-claw" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local HORN = { "#5b4a58", "#8a7466", "#b99f84", "#dcc7a0", "#f3e6c2", "#fff8e4" }
local TIP  = { "#2b1c2e", "#4a2f3c", "#6e4450", "#93606a" }
local LEA  = { "#3a2218", "#5e3a24", "#85552e", "#aa7a42" }
c:groundShadow(34, 56, 12, 2)
local m, n, T, S = G.tube({ {22, 14}, {20, 40}, {46, 40}, {46, 52} }, function(t) return 6.2 * (1 - t) ^ 0.8 + 0.7 end)
local v = X.light(n, { amb = 0.12, wrap = 0.25 })
local bias = {}
m:each(function(x, y) local k = K(x, y)
  local t = T[k]
  local ring = (t * 40) % 4
  if ring < 0.7 and t > 0.12 and t < 0.8 then bias[k] = -1 end
end)
G.tone(c, m, v, HORN, { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias)
-- dark keratin tip
local tipm = HP.mask()
m:each(function(x, y) if T[K(x, y)] > 0.8 then tipm:set(x, y) end end)
G.tone(c, tipm, v, TIP, { 0.25, 0.5, 0.75 })
-- spec streak along upper-left of horn
m:each(function(x, y) local k = K(x, y)
  if S[k] < -0.35 and S[k] > -0.55 and T[k] > 0.2 and T[k] < 0.7 then c:px(x, y, HORN[6]) end
end)
-- leather binding at root
local bind = HP.mask()
m:each(function(x, y) if T[K(x, y)] < 0.17 then bind:set(x, y) end end)
G.tone(c, bind, v, LEA, { 0.3, 0.6, 0.85 })
bind:each(function(x, y) if (x + y) % 4 == 0 then c:px(x, y, LEA[1]) end end)
-- cord loop
G.line(c, { {19, 10}, {17, 7}, {19, 5}, {23, 5}, {25, 7}, {24, 10} }, LEA[4])
c:px(18, 8, LEA[2]) c:px(24, 9, LEA[2])
-- quirk: chip notch on the outer curve
c:px(32, 45, HORN[1]) c:px(33, 45, HORN[2]) c:px(32, 46, HORN[1])
G.fin(c, "titan-claw")
