local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-sword: slim straight sword on the diagonal, steel blade with a fuller, gold crossguard, leather grip, round pommel.
-- quirk: a nick is chewed out of the blade edge and a red ribbon is tied to the grip.
local c = D.new("ico-sword")
D.cyl(c, 22, 42, 56, 8, function(t) return t > 0.93 and 1 or 3.3 - t * 1.2 end, D.GRY, { amb = 0.1 })
D.ln(c, 25, 39, 52, 12, D.GRY[2]) D.ln(c, 23, 40, 51, 11, D.GRY[6])
c:fillMask(c:rect(38, 20, 39, 21), D.INK) c:px(39, 21, D.INK) c:px(40, 22, D.INK) c:px(41, 22, D.GRY[1])
D.cyl(c, 14, 34, 28, 52, function() return 2.2 end, D.YEL, { amb = 0.1 })
D.cyl(c, 19, 45, 11, 53, function() return 2.2 end, D.BRN, { amb = 0.08 })
D.ln(c, 15, 47, 18, 50, D.BRN[2]) D.ln(c, 13, 49, 16, 52, D.BRN[2])
D.disc(c, 9, 56, 3.5, D.YEL)
D.rect(c, 14, 50, 16, 51, D.RED[4]) D.rect(c, 11, 52, 13, 53, D.RED[4]) D.ln(c, 16, 51, 20, 57, D.RED[4]) D.ln(c, 15, 52, 17, 58, D.RED[2])
D.fin()
