local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-trowel-pot: terracotta pot with a sprout and a garden trowel stuck in the soil.
-- quirk: a pink worm peeks out of the soil and waves.
local c = D.new("ico-trowel-pot")
c:groundShadow(32, 58, 17, 2)
D.lit(c, c:line({ {37, 33}, {44, 22} }, 3), D.GRY, 2)
D.lit(c, c:line({ {44, 22}, {52, 8} }, 6), D.WOOD, 2)
D.lit(c, c:poly{ {15, 33}, {49, 33}, {44, 57}, {20, 57} }, D.TERRA, 7)
D.lit(c, c:rrect(11, 27, 53, 36, 3), D.TERRA, 3)
c:fillMask(c:rect(12, 35, 52, 36), D.TERRA[1])
c:fillMask(c:rect(14, 28, 18, 29), D.TERRA[6])
D.lit(c, c:ellipse(32, 28, 19, 3), D.BRN, 1)
D.tube(c, { {20, 28}, {20, 18} }, 3, D.GRN, 1)
D.lit(c, D.ell(14, 17, 6, 3.5, -0.4), D.GRN, 2)
D.lit(c, D.ell(26, 15, 6, 3.5, 0.4), D.GRN, 2)
D.tube(c, { {30, 29}, {32, 22}, {35, 22} }, 3, D.PINK, 1)
c:px(31, 22, INK) c:px(31, 24, CREAM)
c:fillMask(c:rect(26, 42, 38, 43), D.TERRA[5])
D.fin()
