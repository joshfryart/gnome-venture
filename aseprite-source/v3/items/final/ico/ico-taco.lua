local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-taco: crunchy golden taco shell folded open, stuffed with lettuce, tomato and cheese.
-- quirk: a tomato cube has tumbled out and is falling beside the taco.
local c = D.new("ico-taco")
c:groundShadow(32, 56, 24, 2)
for _, o in ipairs{ {14,26,6,5},{24,21,7,6},{35,22,7,6},{46,26,6,5} } do D.lit(c, D.ell(o[1], o[2], o[3], o[4]), D.GRN, 4) end
D.lit(c, D.ell(28, 28, 4, 3), D.RED, 3) D.lit(c, D.ell(40, 28, 4, 3), D.RED, 3)
D.rect(c, 17, 27, 20, 29, D.YEL[4]) D.rect(c, 45, 28, 48, 29, D.YEL[4])
D.lit(c, D.ell(34, 22, 3, 2), D.YEL, 2)
local shell = D.ell(32, 32, 26, 22):clip(c:rect(0, 31, 63, 63))
D.lit(c, shell, D.TAN, 14, { amb = 0.08 })
D.rect(c, 6, 31, 58, 33, D.TAN[5]) D.rect(c, 7, 34, 57, 34, D.TAN[2])
D.ln(c, 10, 38, 18, 47, D.TAN[6]) c:px(26, 44, D.TAN[2]) c:px(38, 46, D.TAN[2]) c:px(46, 40, D.TAN[2])
-- falling tomato cube
D.rect(c, 55, 8, 60, 13, D.RED[4]) D.rect(c, 55, 12, 60, 13, D.RED[2]) D.rect(c, 55, 8, 57, 9, D.RED[6]) D.rect(c, 58, 16, 58, 18, D.RED[3]) 
D.fin()
