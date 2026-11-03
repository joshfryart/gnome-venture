local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-spade: bold garden spade, wooden T-handle, steel shaft and a rounded blade with a rolled collar.
-- quirk: a clod of soil sits on the blade with a pink worm poking out of it.
local c = D.new("ico-spade")
D.cyl(c, 32, 14, 32, 34, function() return 2.4 end, D.GRY, { amb = 0.08 })
D.rrectLit = nil
local grip = c:rrect(18, 6, 46, 14, 3) D.lit(c, grip, D.BRN, 4, { amb = 0.08 })
D.ln(c, 21, 9, 42, 9, D.BRN[6]) D.ln(c, 21, 12, 44, 12, D.BRN[2])
c:px(24, 10, D.BRN[3]) c:px(30, 11, D.BRN[3]) c:px(38, 10, D.BRN[3])
local blade = c:poly{ {22,32},{42,32},{43,44},{38,54},{32,57},{26,54},{21,44} }
D.lit(c, blade, D.GRY, 8, { amb = 0.1 })
D.rect(c, 22, 32, 42, 35, D.GRY[2]) D.rect(c, 22, 32, 41, 33, D.GRY[4])
D.ln(c, 25, 38, 25, 48, D.GRY[6]) D.ln(c, 26, 50, 29, 54, D.GRY[5])
D.rect(c, 29, 30, 35, 36, D.GRY[3]) D.rect(c, 29, 30, 35, 31, D.GRY[5]) c:px(30, 33, D.GRY[6])
-- soil clod + worm
local soil = D.ell(36, 44, 5, 3.2) D.lit(c, soil, D.BRN, 3)
c:px(34, 43, D.BRN[6]) c:px(37, 45, D.BRN[2])
D.rect(c, 37, 38, 38, 42, D.PINK[4]) D.rect(c, 38, 36, 39, 38, D.PINK[4]) c:px(38, 36, D.PINK[6]) c:px(37, 40, D.PINK[2])
D.fin()
