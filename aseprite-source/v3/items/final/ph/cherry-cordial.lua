-- cherry-cordial (v3 first draft, dB15). quirk: red cherry syrup oozes from a crack in the chocolate
local DIR = debug.getinfo(1,"S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR.."/../_helpers/_dB15.lua")
local H, HP, X, B = D.H, D.HP, D.X, D
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local c = D.new("cherry-cordial")
D.shadow(c, 32, 53, 17, 3)
local FOIL = { "#8a6a28", "#c8a040", "#e8c458", "#f6dc78", "#fff0a8", "#fffbd8" }
local CHOC = { "#2a1410", "#442018", "#603024", "#80442e", "#a2603c", "#c88458" }
local cup = c:poly{ {17, 34}, {47, 34}, {44, 52}, {20, 52} }
H.vcyl(c, cup, FOIL, 17, 47)
for x = 20, 44, 3 do B.ln(c, x, 36, x - (x - 32) // 6, 51, FOIL[2], cup) end
local dome = B.ell(32, 33, 15, 11, 0):clip(c:rect(10, 14, 54, 36))
H.lit(c, dome, CHOC, { R = 5 })
-- crack + syrup
B.polyline(c, { {38, 25}, {40, 29}, {39, 33} }, "#7d1f38")
B.ln(c, 39, 33, 39, 40, "#b52e3f")
H.lit(c, B.ell(39, 41, 2, 2.6, 0), "ember", { R = 1.5 })
-- cherry on top
D.bline(c, { {30, 18}, {31, 14}, {33, 11}, {35, 8} }, "#6a7a38")
H.lit(c, B.ell(29, 21, 5, 5, 0), { "#4a1428", "#7d1f38", "#b52e3f", "#d83c44", "#f0585a", "#ff9a8c" }, { R = 3 })
c:px(27, 19, "#ffd4cc") c:px(28, 19, "#ffd4cc")
D.fin()
