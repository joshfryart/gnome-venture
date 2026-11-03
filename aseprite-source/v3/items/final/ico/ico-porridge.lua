local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-porridge: deep blue bowl heaped with creamy porridge, a wooden spoon standing in it.
-- quirk: a pat of butter slides down the heap, leaving a melting yellow drip.
local c = D.new("ico-porridge")
c:groundShadow(32, 57, 21, 2)
local bowl = c:ellipse(32, 36, 24, 22):clip(c:rect(0, 37, 63, 63))
D.lit(c, bowl, D.BLU, 11, { amb = 0.1 })
D.rect(c, 20, 55, 44, 56, D.BLU[1])
D.pts(c, { {14, 45}, {15, 46}, {16, 47}, {17, 48} }, D.BLU[6])
-- spoon first, behind the heap
D.cyl(c, 30, 30, 50, 8, function(t) return 2.2 end, D.BRN, { amb = 0.1 })
D.lit(c, D.ell(29, 31, 4, 3, -0.6), D.BRN, 2)
local heap = c:ellipse(32, 34, 21, 5):add(c:ellipse(32, 31, 14, 6))
D.lit(c, heap, D.CRM, 5, { amb = 0.15 })
local rim = c:ellipse(32, 36, 24, 4):cut(c:ellipse(32, 36, 22, 2)):clip(c:rect(0, 34, 63, 40))
D.lit(c, c:rect(9, 36, 55, 39):clip(c:ellipse(32, 36, 24, 4)), D.BLU, 2)
D.pts(c, { {24, 30}, {25, 29}, {38, 31}, {39, 30}, {30, 33}, {34, 34} }, D.CRM[2])
local b = c:rrect(34, 26, 41, 31, 1)
D.lit(c, b, D.YEL, 2) c:px(35, 26, D.YEL[6])
D.pts(c, { {41, 31}, {41, 32}, {41, 33}, {40, 34} }, D.YEL[4]) c:px(41, 35, D.YEL[3])
D.fin()
