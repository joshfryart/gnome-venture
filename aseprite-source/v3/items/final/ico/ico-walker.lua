local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-walker: bold hiker in mid-stride with a staff and an orange backpack.
-- quirk: the hiker wears a tiny red gnome hat.
local c = D.new("ico-walker")
c:groundShadow(30, 58, 18, 2)
D.lit(c, c:line({ {46, 20}, {50, 56} }, 3), D.WOOD, 1)
D.lit(c, c:line({ {28, 34}, {20, 56} }, 5), D.BLU, 2)
D.lit(c, c:rect(13, 54, 24, 57), D.BRN, 1)
D.lit(c, c:line({ {30, 34}, {40, 46}, {42, 56} }, 5), D.BLU, 2)
D.lit(c, c:rect(39, 54, 49, 57), D.BRN, 1)
D.lit(c, c:rrect(16, 20, 26, 38, 3), D.ORG, 2)
D.lit(c, c:rrect(24, 18, 40, 38, 5), D.GRN, 4)
D.lit(c, c:line({ {37, 24}, {44, 28}, {46, 22} }, 4), D.SKIN, 2)
D.lit(c, c:ellipse(33, 11, 6, 6), D.SKIN, 3)
c:fillMask(c:rect(35, 9, 36, 12), INK)
D.lit(c, c:poly{ {26, 9}, {40, 9}, {33, -1} }:clip(c:rect(0, 1, 63, 63)), D.RED, 2)
D.lit(c, c:poly{ {26, 10}, {40, 10}, {33, 2} }, D.RED, 2)
c:fillMask(c:rect(27, 8, 39, 9), D.RED[2])
D.fin()
