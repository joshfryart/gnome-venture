local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-piece: a single green jigsaw piece, square body with a round knob top and right and a notch bitten out on the left.
-- quirk: a tiny yellow flower is printed on the piece, as if from the picture it belongs to.
local c = D.new("ico-piece")
local m = c:rect(14, 22, 42, 50):add(c:ellipse(28, 18, 5, 5)):add(c:ellipse(47, 36, 5, 5))
m:cut(c:ellipse(13, 36, 5, 5)):cut(c:rect(0, 0, 1, 1))
D.lit(c, m, D.GRN, 9, { amb = 0.1 })
-- bevel line
for x = 17, 40 do c:px(x, 48, D.GRN[2]) end
for y = 25, 47 do c:px(40, y, D.GRN[2]) end
c:fillMask(c:ellipse(29, 38, 2, 2), D.YEL[4])
for _, p in ipairs{ {29, 34}, {29, 42}, {25, 38}, {33, 38} } do c:fillMask(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), D.PINK[4]) end
c:px(29, 38, D.ORG[4]) c:px(29, 39, D.ORG[4])
c:px(16, 25, D.GRN[6]) c:px(17, 25, D.GRN[6])
D.fin()
