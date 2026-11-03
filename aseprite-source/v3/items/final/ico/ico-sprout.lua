local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-sprout: a seedling with two broad leaves rising from a mound of soil.
-- quirk: a bright dewdrop balances on the right leaf's tip.
local c = D.new("ico-sprout")
c:groundShadow(32, 57, 18, 2)
local mound = c:ellipse(32, 52, 18, 6):clip(c:rect(0, 46, 63, 58)) D.lit(c, mound, D.BRN, 6, { amb = 0.1 })
c:px(24, 49, D.BRN[6]) c:px(25, 49, D.BRN[6]) c:px(38, 51, D.BRN[2]) c:px(30, 52, D.BRN[2])
D.cyl(c, 32, 50, 32, 28, function() return 1.7 end, D.GRN, { amb = 0.1 })
D.leaf(c, 31, 30, 6, 10, 8, D.GRN, { 8, 14 })
D.leaf(c, 33, 28, 58, 8, 8, D.GRN, { 8, 14 })
D.leaf(c, 32, 36, 18, 28, 4, D.GRN)
c:fillMask(c:ellipse(53, 9, 2, 3), D.BLU[4]) c:px(52, 8, D.CREAM) D.rect(c, 53, 11, 54, 11, D.BLU[2])
D.fin()
