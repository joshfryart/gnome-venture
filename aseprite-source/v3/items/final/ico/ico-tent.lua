local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-tent: green canvas A-frame tent with a dark open doorway and tied-back flaps, ridge pole above.
-- quirk: a mismatched brown patch is stitched onto the left wall and a tiny pennant flies from the peak.
local c = D.new("ico-tent")
c:groundShadow(32, 56, 26, 2)
D.rect(c, 32, 4, 32, 12, D.BRN[4]) c:fillMask(c:poly{ {33,4},{33,10},{42,7} }, D.RED[4]) c:px(34, 6, D.RED[6])
local t = c:poly{ {32,10},{57,54},{7,54} }
D.lit(c, t, D.GRN, 12, { amb = 0.1 })
D.ln(c, 32, 12, 9, 53, D.GRN[6]) D.ln(c, 32, 12, 55, 53, D.GRN[2]) D.ln(c, 33, 12, 56, 53, D.GRN[1])
local door = c:poly{ {32,26},{43,54},{21,54} }
c:fillMask(door, D.PURP[1]) D.ln(c, 32, 30, 32, 53, D.PURP[2])
D.lit(c, c:poly{ {32,24},{20,54},{14,54},{28,26} }, D.GRN, 3, { amb = 0.3 })
D.lit(c, c:poly{ {32,24},{44,54},{50,54},{36,26} }, D.GRN, 3, { amb = 0.3 })
D.ln(c, 28, 27, 17, 53, D.GRN[2]) D.ln(c, 36, 27, 47, 53, D.GRN[1])
D.rect(c, 14, 38, 20, 44, D.BRN[4]) D.rect(c, 14, 38, 20, 38, D.BRN[6]) D.rect(c, 14, 44, 20, 44, D.BRN[2])
for x = 14, 19, 2 do c:px(x, 40, D.YEL[4]) c:px(x, 42, D.YEL[4]) end
D.rect(c, 5, 54, 59, 54, D.GRN[1])
D.fin()
