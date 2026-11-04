-- titan-claw (lean D3o_4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function paint(c, m, ramp, f) m:each(function(x, y) local i = floor(f(x, y) + 0.5); c:put(x, y, ramp[max(1, min(#ramp, i))]) end) end
local H = function(x, y, s) return X.hash(x, y, s) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "titan-claw" }
local BN = { "#5a3a2a", "#8a5c3a", "#b88852", "#dcb878", "#f0d9a0", "#fff2cc" }
local LT = { "#2e1c1a", "#4e2e24", "#74442e", "#9a6038" }
c:groundShadow(26, 55, 15, 2)
local m, n, T = G.tube({ {20,47},{16,31},{28,17},{50,9} }, function(t) return 1.0 + 8.2 * (1 - t) ^ 0.8 end)
local v = X.light(n, { amb = 0.1, wrap = 0.3 })
G.tone(c, m, v, BN, { 0.2, 0.4, 0.56, 0.72, 0.88 })
m:each(function(x, y) local k = K(x, y); local t = T[k]
  if t > 0.16 and ((t * 11) % 1) < 0.14 then c:put(x, y, BN[2]) end      -- growth ridges
  if t > 0.84 then c:put(x, y, (t > 0.93) and "#6a2e24" or "#9a4a30") end    -- dark tip
  if t < 0.14 then c:put(x, y, LT[1 + floor(v[k] * 3.99)]) end           -- leather cuff
end)
-- cuff stitching + studs
for _, p in ipairs{ {14,49},{18,48},{22,47},{26,46} } do end
m:each(function(x, y) local k = K(x, y); if T[k] < 0.14 and (x + y) % 4 == 0 then c:put(x, y, "#e0c080") end end)
-- gloss streak on the lit side, quirk: hairline crack
for t = 0.25, 0.7, 0.05 do
  local f = t / 1
  local x = floor(20 - 7 * sin(f * 2.4) + 0.5)
end
c:put(21, 38, BN[6]) c:put(21, 37, BN[6]) c:put(22, 35, BN[6]) c:put(23, 33, BN[5]) c:put(26, 29, BN[6]) c:put(25, 30, BN[5])
c:put(27, 36, BN[1]) c:put(28, 37, BN[1]) c:put(28, 38, BN[2]) c:put(29, 39, BN[1])
G.fin(c, "titan-claw")
