local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- basil-pesto: a squat glass jar of dark-green pesto with a cork lid, a basil leaf tag and a wooden spoon. quirk: an oil drip runs down the glass.
local c = D.new("basil-pesto")
c:groundShadow(30, 57, 17, 2)
local jar = c:poly{ {14, 22}, {46, 22}, {49, 28}, {49, 52}, {45, 55}, {15, 55}, {11, 52}, {11, 28} }
D.lit(jar, D.GREY, 4)
c:fillMask(c:poly{ {13, 28}, {47, 28}, {47, 52}, {44, 54}, {16, 54}, {13, 52} }, "#2e5a2a")
D.lit(c:poly{ {13, 28}, {47, 28}, {47, 52}, {44, 54}, {16, 54}, {13, 52} }, D.LEAF, 5)
for _, p in ipairs{{20, 36}, {30, 44}, {38, 34}, {25, 49}} do D.px(p[1], p[2], "#fff0a8") c:px(p[1] + 1, p[2] + 1, "#9dd06c") end
D.ln(15, 29, 15, 50, "#cac6d2") D.px(16, 27, "#f0f1fa")
D.lit(c:rect(15, 14, 45, 22), D.TAN, 2.5) for x = 18, 42, 5 do D.ln(x, 15, x, 21, D.TAN[2]) end
D.lit(D.ell(30, 42, 7, 5, 0), D.CRM, 2.5) D.lf(30, 42, 4, 1.6, 0.6, D.LEAF)
local sp = c:line({{54, 6}, {50, 20}}, 2) D.lit(sp, D.BRN, 1.5)
D.lit(D.ell(54, 8, 3, 4, 0.2), D.BRN, 2) c:px(53, 6, "#c98a54")
c:px(48, 40, "#f8d048") c:px(48, 41, "#f8d048") c:px(48, 42, "#ffe46e") c:px(47, 43, "#eab32e") c:px(48, 43, "#f8d048")
D.fin()
