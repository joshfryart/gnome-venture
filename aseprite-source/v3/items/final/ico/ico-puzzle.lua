local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-puzzle: two jigsaw pieces snapped together, blue on the left and orange on the right.
-- quirk: the orange piece is not seated yet and sits 3 px high, still wiggling.
local c = D.new("ico-puzzle")
local o = c:rect(34, 16, 56, 42):add(c:ellipse(45, 12, 4, 4))
o:cut(c:ellipse(33, 29, 5, 5))
D.lit(c, o, D.ORG, 8, { amb = 0.1 })
D.ln(c, 36, 41, 55, 41, D.ORG[2]) D.ln(c, 55, 19, 55, 41, D.ORG[2])
local b = c:rect(8, 22, 31, 49):add(c:ellipse(34, 36, 5, 5)):add(c:ellipse(19, 53, 4, 4))
b:cut(c:ellipse(8, 36, 4, 4))
D.lit(c, b, D.BLU, 9, { amb = 0.1 })
D.ln(c, 11, 48, 30, 48, D.BLU[2])
D.pts(c, { {12, 25}, {13, 25}, {14, 25}, {12, 26} }, D.BLU[6])
D.pts(c, { {38, 19}, {39, 19}, {38, 20} }, D.ORG[6])
-- wiggle marks
D.pts(c, { {58, 8}, {59, 9}, {60, 8}, {61, 9} }, D.CRM[2])
D.pts(c, { {58, 24}, {59, 25}, {60, 24} }, D.CRM[2])
c:sparkle(25, 14)
D.fin()
