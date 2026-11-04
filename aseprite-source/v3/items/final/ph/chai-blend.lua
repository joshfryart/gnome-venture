-- chai-blend (v3 first draft, dB15). quirk: a star anise floats on the chai
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("chai-blend")
D.shadow(c, 30, 53, 18, 3)
local body = c:rrect(14, 26, 44, 51, 5)
H.vcyl(c, body, "ember", 14, 44)
for x = 15, 43 do if body:has(x, 36) then c:px(x, 36, "#fff4d6") end if body:has(x, 37) then c:px(x, 37, "#fff4d6") end end
-- little spice dots on the band
for x = 17, 41, 4 do c:px(x, 40, "#f5b82e") end
local hm = H.sweep({ {44, 31}, {55, 29}, {55, 46}, {43, 45} }, function() return 1.8 end)
H.lit(c, hm, "ember", { R = 1.5 })
local top = B.ell(29, 27, 14, 3.2, 0)
H.lit(c, top, { "#51302b", "#864c33", "#a2603c", "#b97a4a", "#d09a60", "#e8b982" }, { R = 2 })
-- star anise
local sx, sy = 25, 27
for a = 0, 4 do local ang = a * 2 * pi / 5 - pi / 2 B.ln(c, sx, sy, floor(sx + cos(ang) * 3 + .5), floor(sy + sin(ang) * 1.6 + .5), "#7a3f2a") end
c:px(sx, sy, "#3a1a14")
-- cinnamon stick
H.cyl(c, 36, 28, 50, 10, function() return 1.7 end, "wood")
H.lit(c, B.ell(50, 10, 2, 1.5, 0), { "#51302b", "#864c33", "#a2603c", "#c88a50", "#e8b982", "#f6dcb0" }, { R = 1 })
-- steam
B.polyline(c, { {20, 22}, {18, 18}, {21, 14}, {19, 10} }, "#fff4d6")
B.polyline(c, { {27, 20}, {25, 16}, {28, 12} }, "#e2e0e6")
D.fin()
