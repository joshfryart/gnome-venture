local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-cross: bold rounded red healing cross, glossy, with a cream plaster across the corner.
-- quirk: a little cream bandage plaster stuck across the lower arm.
local c = D.new("ico-cross")
local m = c:rrect(22, 6, 41, 57, 3):add(c:rrect(7, 20, 56, 43, 3))
D.lit(m, D.RED, 7)
-- groove between arms for inner seam
D.fill(c:rect(24, 22, 39, 23), D.RED[4])
-- plaster
local pl = c:poly{ { 20, 47 }, { 24, 43 }, { 44, 52 }, { 40, 56 } }
D.fill(pl, D.CREAM[4]) D.fill(pl:shift(0, 1):cut(pl), D.CREAM[2])
D.px(30, 47, D.CREAM[2]) D.px(32, 48, D.CREAM[2]) D.px(34, 49, D.CREAM[2]) D.px(28, 46, D.CREAM[5])
D.px(26, 14, D.RED[6]) D.px(27, 14, D.RED[6])
D.fin()
