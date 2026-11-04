-- tin-watering-can (lean D3o_4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function paint(c, m, ramp, f) m:each(function(x, y) local i = floor(f(x, y) + 0.5); c:put(x, y, ramp[max(1, min(#ramp, i))]) end) end
local H = function(x, y, s) return X.hash(x, y, s) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tin-watering-can" }
local TN = { "#303a56", "#4c5a7a", "#7384a4", "#a2b2c8", "#cfdae8", "#f2f7fc" }
c:groundShadow(30, 55, 20, 2)
-- rear handle ring
local hd = c:ellipse(15, 37, 8, 11); hd:cut(c:ellipse(15, 37, 5, 8)); hd:cut(c:rect(15, 20, 30, 56))
paint(c, hd, TN, function(x, y) return 2.8 + (y < 34 and 0.8 or 0) - (x - 7) * 0.1 end)
-- spout
local sm, sn = G.tube({ {36,46},{42,42},{46,32},{52,22} }, function(t) return 3.2 - 1.6 * t end)
G.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), TN, { 0.2, 0.4, 0.58, 0.74, 0.88 })
-- rose cap
local rose = c:ellipse(53, 20, 4, 3)
paint(c, rose, TN, function(x, y) return 4.5 - (x - 49) * 0.2 - (y - 17) * 0.3 end)
for _, p in ipairs{ {51,20},{53,19},{55,21},{53,21} } do c:put(p[1], p[2], TN[1]) end
-- quirk: a water drop
c:put(58, 24, "#7fd7ee") c:put(58, 25, "#b8f0fa") c:put(57, 25, "#4aa7d0") c:put(58, 26, "#4aa7d0")
-- body
local body = c:rrect(18, 28, 42, 52, 3)
paint(c, body, TN, function(x, y) local t = (x - 18) / 24; local i = 5.2 - t * 4; if x == 21 or x == 22 then i = 5.8 end; if y == 51 or y == 52 then i = i - 1 end; return i end)
-- opening
local op = c:ellipse(30, 28, 12, 3)
paint(c, op, TN, function(x, y) local d = ((x - 30) / 12) ^ 2 + ((y - 28) / 3) ^ 2; return d > 0.55 and 5 or 1 end)
c:put(27, 27, "#4aa7d0") c:put(28, 27, "#7fd7ee") c:put(31, 28, "#4aa7d0")
-- hoop bands + rivets
for _, y in ipairs{ 33, 46 } do for x = 18, 42 do local t = (x - 18) / 24; c:put(x, y, (t < 0.3) and TN[4] or (t < 0.7) and TN[2] or TN[1]); c:put(x, y + 1, (t < 0.5) and TN[2] or TN[1]) end end
for _, p in ipairs{ {22,39},{30,39},{38,39},{26,42},{34,42} } do c:put(p[1], p[2], TN[6]) c:put(p[1] + 1, p[2] + 1, TN[1]) end
-- top handle arch
local ar = c:ellipse(30, 24, 9, 9); ar:cut(c:ellipse(30, 24, 6, 6)); ar:cut(c:rect(18, 24, 42, 40))
paint(c, ar, TN, function(x, y) return 4.6 - (x - 21) * 0.12 - (y - 15) * 0.15 end)
G.fin(c, "tin-watering-can")
