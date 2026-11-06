-- tin-lantern (lean D3o_4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function paint(c, m, ramp, f) m:each(function(x, y) local i = floor(f(x, y) + 0.5); c:put(x, y, ramp[max(1, min(#ramp, i))]) end) end
local H = function(x, y, s) return X.hash(x, y, s) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tin-lantern" }
local TN = { "#303a56", "#4c5a7a", "#7384a4", "#a2b2c8", "#cfdae8", "#f2f7fc" }
local GL = { "#7a3a1c", "#b3571c", "#e8821e", "#f9b53a", "#fdd96a", "#fff3b4" }
c:groundShadow(32, 54, 15, 2)
-- handle ring
local ring = c:ellipse(32, 11, 8, 7); ring:cut(c:ellipse(32, 11, 5, 4))
ring:cut(c:rect(20, 13, 44, 20))
paint(c, ring, TN, function(x, y) return 4.2 - (x - 24) * 0.12 - (y - 5) * 0.1 end)
-- cap
local cap = c:poly{ {26,17},{38,17},{46,26},{18,26} }
paint(c, cap, TN, function(x, y) local i = 4.6 - (x - 18) * 0.08 - (y - 17) * 0.2; if y == 17 then i = 5.8 end; if y == 26 then i = 1.5 end; return i end)
c:put(30, 20, TN[1]) c:put(31, 20, TN[1]) c:put(31, 21, TN[2]) -- quirk: a dent
c:put(32, 17, TN[6])
-- glass cage
local gl = c:rect(20, 27, 44, 47)
paint(c, gl, GL, function(x, y) local d = sqrt(((x - 32) * 0.8) ^ 2 + (y - 38) ^ 2); return 5.8 - d * 0.42 end)
-- flame
local fl = c:poly{ {32,31},{35,37},{35,41},{32,43},{29,41},{29,37} }
paint(c, fl, GL, function(x, y) return (abs(x - 32) < 1 and y > 35) and 6 or 5 end)
c:put(32, 33, GL[6]) c:put(32, 32, GL[5])
c:put(32, 44, "#303a56") c:put(31, 45, "#4c5a7a") c:put(33, 45, "#4c5a7a")
-- cracked pane
c:put(37, 29, GL[1]) c:put(38, 30, GL[1]) c:put(38, 31, GL[1]) c:put(39, 32, GL[1])
-- glint on glass
c:put(23, 30, GL[6]) c:put(23, 31, GL[6]) c:put(24, 29, GL[6])
-- frame bars
for _, bx in ipairs{ 20, 43 } do c:fillMask(c:rect(bx, 27, bx + 1, 47), TN[3]) c:fillMask(c:rect(bx, 27, bx, 47), TN[5]) c:fillMask(c:rect(bx + 1, 27, bx + 1, 47), TN[2]) end
c:fillMask(c:rect(31, 27, 32, 47), TN[2]) c:fillMask(c:rect(31, 27, 31, 47), TN[4])
c:fillMask(c:rect(20, 27, 44, 27), TN[2])
-- base
local base = c:rrect(17, 48, 47, 53, 2)
paint(c, base, TN, function(x, y) local i = 4.5 - (x - 17) * 0.07 - (y - 48) * 0.35; if y == 53 then i = 1.3 end; return i end)
for _, x in ipairs{ 22, 32, 42 } do c:put(x, 50, TN[1]) end
G.fin(c, "tin-lantern")
