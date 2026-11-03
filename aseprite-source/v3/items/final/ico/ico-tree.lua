local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-tree: round oak with a thick trunk, three-lobe canopy and red apples.
-- quirk: a knot-hole in the trunk with two owl eyes peeking out.
local c = D.new("ico-tree")
c:groundShadow(32, 57, 18, 2)
local tr = c:poly{ {27, 34}, {37, 34}, {39, 54}, {44, 57}, {20, 57}, {25, 54} }
D.lit(c, tr, D.WOOD, 4)
for _, x in ipairs{ 28, 36 } do c:fillMask(c:rect(x, 42, x, 53), D.WOOD[2]) end
c:fillMask(c:ellipse(32, 44, 3, 4), D.WOOD[1])
c:fillMask(c:rect(30, 42, 30, 43), CREAM) c:fillMask(c:rect(34, 42, 34, 43), CREAM)
c:px(31, 43, INK) c:px(33, 43, INK)
local can = c:ellipse(32, 20, 16, 13):add(c:ellipse(19, 30, 12, 10)):add(c:ellipse(45, 30, 12, 10)):add(c:ellipse(32, 31, 17, 10))
D.lit(c, can, D.GRN, 9, { amb = 0.05 })
for _, p in ipairs{ {26, 16}, {38, 22}, {20, 30}, {44, 33}, {31, 35} } do
  c:fillMask(c:ellipse(p[1], p[2], 2, 2), D.GRN[2]) end
for _, p in ipairs{ {24, 20}, {40, 28}, {30, 29} } do
  D.lit(c, c:ellipse(p[1], p[2], 2.5, 2.5), D.RED, 2) c:px(p[1] - 1, p[2] - 1, D.RED[6]) end
D.fin()
