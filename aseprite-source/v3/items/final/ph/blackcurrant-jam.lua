local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("blackcurrant-jam")
-- blackcurrant-jam: stubby jar of near-black purple jam under a gingham cloth lid tied with a string; spoon in jar. quirk: a dab of jam on the rim.
D.shadow(32, 57, 15, 2)
D.vbody(16, 26, 48, 55, 6, D.JAM)
D.c:fillMask(D.c:rect(21, 31, 25, 50), "#a04898")
D.P({{14,22},{50,22},{54,30},{10,30}}, D.BLUE, 1.5)
for x = 14, 50, 4 do D.ln(x, 22, x - 1, 29, "#fff4d6") end
for y = 24, 28, 4 do D.ln(12, y, 52, y, "#6490d2") end
D.ln(10, 29, 54, 29, "#1c2e5e")
D.ln(16, 31, 48, 31, "#d8bd7c") D.px(46, 32, "#d8bd7c") D.px(47, 34, "#d8bd7c")
D.c:fillMask(D.c:rect(23, 38, 41, 50), "#fbf0c8") D.c:fillMask(D.c:rect(23, 38, 41, 39), "#d8bd7c")
D.E(28, 44, 2, 2, 0, D.INDIGO, 1) D.E(33, 45, 2, 2, 0, D.INDIGO, 1) D.E(31, 42, 1.6, 1.6, 0, D.INDIGO, 1)
D.ln(44, 4, 38, 22, "#a35f3c") D.E(45, 4, 2.6, 2, 0.4, D.BRN, 1.5)
D.E(50, 33, 2, 1.5, 0, D.JAM, 1) D.px(49, 32, "#cc7cc0")
D.fin()
