-- toad-jewel (lean D3o_4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function paint(c, m, ramp, f) m:each(function(x, y) local i = floor(f(x, y) + 0.5); c:put(x, y, ramp[max(1, min(#ramp, i))]) end) end
local H = function(x, y, s) return X.hash(x, y, s) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "toad-jewel" }
local GM = { "#12392e", "#1c5d40", "#2e8a4a", "#58b85a", "#94d96e", "#d4f5a0" }
local GD = { "#6a3e1a", "#a06a20", "#d09a2c", "#f0c448", "#fde68a", "#fffbe0" }
c:groundShadow(32, 56, 14, 2)
-- pendant loop
local lp = c:ellipse(32, 10, 4, 4); lp:cut(c:ellipse(32, 10, 2, 2))
paint(c, lp, GD, function(x, y) return 4.3 - (x - 28) * 0.2 end)
-- bezel with wart bumps
local bz = c:ellipse(32, 33, 19, 18)
for i = 0, 9 do local a = i / 10 * 2 * pi + 0.3; bz:add(c:ellipse(floor(32 + 20 * cos(a) + 0.5), floor(33 + 19 * sin(a) + 0.5), 2, 2)) end
paint(c, bz, GD, function(x, y) return 4.4 - ((x - 32) * 0.07 + (y - 33) * 0.1) + (H(x, y, 3) - 0.5) * 0.8 end)
for i = 0, 9 do local a = i / 10 * 2 * pi + 0.3; c:put(floor(32 + 20 * cos(a) - 0.5), floor(33 + 19 * sin(a) - 0.5), GD[6]) end
-- gem
local gm = c:ellipse(32, 33, 15, 14)
paint(c, gm, GM, function(x, y) local d = sqrt(((x - 32) / 15) ^ 2 + ((y - 33) / 14) ^ 2); return 5.4 - d * 3 - (x - 32) * 0.03 + (y - 33) * -0.05 end)
-- facet lines
for k = 0, 7 do local a = k / 8 * 2 * pi + 0.4; for r = 9, 14 do c:put(floor(32 + r * cos(a) + 0.5), floor(33 + r * 0.93 * sin(a) + 0.5), GM[2 + (cos(a) > 0 and 0 or 1)]) end end
-- iris + horizontal toad pupil
local ir = c:ellipse(32, 33, 8, 6)
paint(c, ir, GD, function(x, y) local d = sqrt(((x - 32) / 8) ^ 2 + ((y - 33) / 6) ^ 2); return 5.4 - d * 3 end)
local pu = c:ellipse(32, 33, 5, 2)
c:fillMask(pu, "#1a0f12")
-- glints
c:put(25, 26, "#fffbe0") c:put(26, 26, "#fffbe0") c:put(25, 27, "#fffbe0") c:put(37, 38, GM[6]) c:put(28, 32, "#fffbe0")
G.fin(c, "toad-jewel")
