local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-pudding: wobbly vanilla flan on a grey plate, dark caramel cap dripping down the sides.
-- quirk: a glossy cherry on top, and a drip of caramel pooling on the plate.
local c = D.new("ico-pudding")
c:groundShadow(32, 57, 25, 2)
local plate = c:ellipse(32, 51, 25, 6)
D.lit(c, plate, D.GRY, 4, { amb = 0.1 })
c:fillMask(c:ellipse(32, 50, 17, 3), D.GRY[2])
local flan = c:poly{ {17, 51}, {21, 28}, {43, 28}, {47, 51} }:add(c:ellipse(32, 51, 15, 3))
D.lit(c, flan, D.YEL, 9, { amb = 0.1 })
D.pts(c, { {19, 38}, {20, 39}, {18, 44}, {19, 45} }, D.YEL[6])
local cap = c:ellipse(32, 29, 13, 5):add(c:poly{ {19, 29}, {45, 29}, {44, 36}, {20, 36} })
cap:clip(c:rect(0, 0, 63, 37))
local drips = c:rect(19, 29, 45, 33)
for _, d in ipairs{ {22, 41}, {27, 37}, {32, 44}, {38, 39}, {43, 36} } do drips:add(c:rect(d[1], 33, d[1] + 2, d[2])) end
cap:add(drips):clip(c:poly{ {17, 20}, {47, 20}, {47, 48}, {17, 48} })
cap:cut(c:rect(0, 0, 63, 23))
cap:clip(flan)
D.lit(c, cap, D.BRN, 4, { amb = 0.15 })
D.lit(c, c:ellipse(32, 28, 13, 4), D.ORG, 3)
D.ln(c, 20, 28, 44, 28, D.BRN[3])
D.lit(c, c:ellipse(32, 22, 4, 4), D.RED, 3) c:px(30, 20, CREAM) c:px(31, 20, CREAM)
D.ln(c, 33, 19, 36, 14, D.GRN[2])
D.rect(c, 26, 52, 28, 53, D.BRN[3]) c:px(27, 54, D.BRN[2])
D.fin()
