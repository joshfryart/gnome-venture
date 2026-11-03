local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-question: big fat blue question mark, bevelled and glossy.
-- quirk: the dot is a round little bouncing ball, with two motion ticks above it.
local c = D.new("ico-question")
local a = D.sweep({ {20, 22}, {20, 6}, {45, 6}, {45, 22} }, function(t) return 4.6 end, 80)
local b = D.sweep({ {45, 22}, {45, 32}, {32, 32}, {32, 41} }, function(t) return 4.6 end, 80)
a:add(b)
D.lit(c, a, D.BLU, 5, { amb = 0.06 })
D.pts(c, { {23, 13}, {24, 11}, {26, 10}, {28, 9}, {29, 9} }, D.BLU[6])
D.pts(c, { {24, 14}, {25, 12}, {27, 11} }, D.BLU[5])
D.lit(c, c:ellipse(32, 53, 5, 5), D.BLU, 4)
c:px(30, 51, CREAM) c:px(31, 51, CREAM)
D.pts(c, { {25, 46}, {26, 47}, {38, 46}, {37, 47} }, D.BLU[3])
D.pts(c, { {24, 43}, {25, 44}, {39, 43}, {38, 44} }, D.BLU[3])
D.fin()
