local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-turtle: friendly green turtle in side view, domed hex shell, stubby legs.
-- quirk: a tiny red mushroom grows on its shell.
local c = D.new("ico-turtle")
c:groundShadow(30, 57, 22, 2)
D.lit(c, c:poly{ {10, 44}, {2, 46}, {10, 49} }, D.GRN, 1)
D.lit(c, c:rrect(15, 44, 24, 54, 3), D.GRN, 3)
D.lit(c, c:rrect(37, 44, 46, 54, 3), D.GRN, 3)
D.lit(c, c:ellipse(53, 37, 7, 6), D.GRN, 4)
D.lit(c, c:rect(10, 41, 50, 48), D.YEL, 2)
local sh = c:ellipse(30, 42, 21, 17) sh:clip(c:rect(0, 0, 63, 44))
D.lit(c, sh, D.TEAL, 8, { amb = 0.05 })
local L = D.TEAL[2]
for _, ln in ipairs{ { {22, 27}, {20, 43} }, { {32, 24}, {32, 43} }, { {42, 27}, {44, 43} }, { {21, 32}, {43, 32} } } do D.ln(c, ln[1][1], ln[1][2], ln[2][1], ln[2][2], L, sh) end
c:fillMask(c:rect(14, 43, 46, 43), D.TEAL[1])
c:eyeSmall(55, 33)
c:px(57, 40, D.GRN[1]) c:px(58, 40, D.GRN[1])
c:fillMask(c:rect(52, 41, 55, 41), D.RED[3])
D.lit(c, c:rect(37, 18, 39, 23), D.CRM, 1)
D.lit(c, c:ellipse(38, 17, 5, 3), D.RED, 2) c:px(36, 16, CREAM) c:px(40, 17, CREAM)
D.fin()
