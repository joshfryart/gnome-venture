local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("blueberry-jam")
-- blueberry-jam: wide low jar of indigo jam, flat tin lid with a berry badge, wax-paper ruffle, small spoon. quirk: the ruffle is tied with a berry-stem bow.
D.shadow(32, 57, 17, 2)
D.vbody(12, 30, 52, 55, 6, D.INDIGO)
D.c:fillMask(D.c:rect(17, 35, 21, 52), "#9a96e0")
D.P({{10,22},{54,22},{56,29},{8,29}}, D.CRM, 1.5)
for x = 11, 54, 5 do D.ln(x, 22, x, 28, "#c9a98a") end
D.vbody(14, 14, 50, 24, 3, D.STEEL)
D.ln(16, 16, 40, 16, "#f0f1fa") D.px(46, 22, "#2f3350")
D.E(32, 19, 3, 3, 0, D.BLUE, 1.5) D.px(31, 18, "#fff4d6") D.px(33, 15, "#6ab455") D.px(34, 14, "#6ab455")
D.c:fillMask(D.c:rect(22, 38, 42, 50), "#fbf0c8") D.c:fillMask(D.c:rect(22, 38, 42, 39), "#d8bd7c")
D.E(28, 44, 2.4, 2.4, 0, D.BLUE, 1) D.E(34, 45, 2.4, 2.4, 0, D.BLUE, 1) D.E(31, 42, 1.8, 1.8, 0, D.BLUE, 1) D.px(31, 41, "#fff4d6")
D.ln(8, 30, 6, 36, "#6a4a38") D.ln(56, 30, 58, 35, "#6a4a38") D.px(5, 37, "#7c6a82")
D.fin()
