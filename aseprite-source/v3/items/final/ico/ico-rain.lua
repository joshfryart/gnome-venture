local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-rain: puffy grey cloud with a flat underside and slanting blue raindrops.
-- quirk: one drop has already hit the ground and bounced into a tiny splash crown.
local c = D.new("ico-rain")
local cl = c:ellipse(20, 26, 10, 9):add(c:ellipse(33, 20, 12, 12)):add(c:ellipse(46, 27, 10, 9)):add(c:rect(14, 28, 52, 35))
cl:cut(c:rect(0, 36, 63, 63))
D.lit(c, cl, D.GRY, 11, { amb = 0.1 })
D.rect(c, 14, 35, 52, 35, D.GRY[2])
D.pts(c, { {27, 14}, {28, 13}, {29, 13}, {18, 21}, {17, 22} }, D.GRY[6])
local function drop(x, y)
  local m = c:poly{ {x + 1, y}, {x + 3, y + 4}, {x + 3, y + 5}, {x + 2, y + 6}, {x, y + 6}, {x - 1, y + 5}, {x - 1, y + 4} }
  D.lit(c, m, D.BLU, 2, { amb = 0.1 })
  c:px(x, y + 4, D.BLU[6])
end
drop(16, 40) drop(28, 42) drop(40, 40) drop(22, 50) drop(34, 52) drop(46, 49)
-- splash
D.pts(c, { {52, 58}, {53, 58}, {54, 58}, {55, 58}, {56, 58}, {50, 56}, {51, 57}, {58, 56}, {57, 57} }, D.BLU[4])
D.pts(c, { {53, 59}, {54, 59}, {55, 59}, {52, 55}, {58, 55} }, D.BLU[2])
D.fin()
