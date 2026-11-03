local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- bean-tamales: two corn-husk-wrapped tamales, one lying tied with a husk strip, one opened to show golden masa packed with red-brown beans. quirk: a bean has rolled out onto the husk.
local c = D.new("bean-tamales")
c:groundShadow(32, 56, 20, 2)
local t1 = c:poly{ {6, 40}, {12, 28}, {40, 30}, {44, 44}, {34, 52}, {12, 50} }
D.lit(t1, D.HUSK, 4)
for _, y in ipairs{33, 37, 41, 45, 49} do D.ln(11 + (y - 33) / 2, y, 40 - (y > 45 and 5 or 0), y + 1, D.HUSK[2]) end
D.ln(26, 29, 29, 51, "#d8bd7c") D.ln(27, 29, 30, 51, "#8e7242") D.ln(28, 29, 31, 51, "#6a5030")
D.lit(c:poly{ {26, 36}, {35, 36}, {35, 44}, {26, 44} }, D.TAN, 1.5)
local t2 = c:poly{ {34, 20}, {58, 18}, {60, 34}, {54, 42}, {36, 40} }
D.lit(t2, D.HUSK, 4)
D.ln(36, 22, 31, 14, "#d8bd7c") D.ln(37, 22, 33, 12, "#b8985a") D.ln(38, 21, 38, 12, "#d8bd7c") D.ln(50, 20, 54, 11, "#b8985a")
local masa = c:poly{ {40, 26}, {56, 25}, {56, 33}, {50, 38}, {40, 36} }
D.lit(masa, D.GRAIN, 3)
for _, p in ipairs{{44, 29}, {50, 28}, {47, 34}, {53, 32}} do D.lit(D.ell(p[1], p[2], 1.8, 1.4, 0.4), D.RED, 1.2) end
D.lit(D.ell(18, 55, 2, 1.5, 0.4), D.RED, 1.2)
D.fin()
