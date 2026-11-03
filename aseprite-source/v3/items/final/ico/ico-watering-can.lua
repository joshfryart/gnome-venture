local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-watering-can: blue can with a loop handle, long spout and a rose, drops falling.
-- quirk: a daisy is painted on the side.
local c = D.new("ico-watering-can")
D.lit(c, c:line({ {18, 25}, {20, 12}, {34, 12}, {36, 25} }, 3), D.BLU, 2)
D.lit(c, c:line({ {39, 46}, {52, 28} }, 4), D.BLU, 2)
D.lit(c, c:poly{ {50, 21}, {60, 27}, {55, 34}, {47, 30} }, D.GRY, 2)
for _, p in ipairs{ {56, 38}, {59, 44}, {53, 47} } do D.lit(c, c:ellipse(p[1], p[2], 1.5, 2), D.ICE, 1) end
D.lit(c, c:rrect(10, 24, 42, 54, 4), D.BLU, 6)
D.lit(c, c:rect(10, 24, 42, 28), D.BLU, 2)
c:fillMask(c:rect(11, 28, 41, 28), D.BLU[1])
c:fillMask(c:rect(12, 49, 40, 49), D.BLU[2])
for _, a in ipairs{ {0,-4},{4,0},{0,4},{-4,0} } do c:fillMask(c:ellipse(25 + a[1], 40 + a[2], 2, 2), CREAM) end
c:fillMask(c:ellipse(25, 40, 2, 2), D.YEL[4])
D.fin()
