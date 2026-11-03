local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-pick: bold mining pick, a curved steel head on a long wooden haft with a rope-wrapped grip.
-- quirk: a nick is bitten out of one pick tip and a spark of rock chip flies off.
local c = D.new("ico-pick")
local haft = D.cyl(c, 36, 20, 27, 58, function(t) return 2.6 end, D.BRN, { amb = 0.08 })
D.ln(c, 35, 22, 28, 56, D.BRN[5], haft)
for y = 44, 54, 3 do local x = floor(36 - (y - 20) * 9 / 38 + .5) D.rect(c, x - 2, y, x + 2, y, D.TAN[4]) D.rect(c, x - 2, y + 1, x + 2, y + 1, D.TAN[2]) end
local head, T = D.sweep({ {7, 30}, {14, 7}, {50, 7}, {57, 30} }, function(t) return 3.7 - 1.6 * abs(t - 0.5) * 2 + 0.6 end, 80)
local hm = head:copy()
D.lit(c, hm, D.GRY, 4, { amb = 0.1 })
c:fillMask(c:ellipse(34, 20, 4, 4), D.GRY[3])
D.lit(c, c:ellipse(34, 20, 4, 4), D.GRY, 3)
c:px(30, 10, D.GRY[6]) c:px(31, 10, D.GRY[6]) c:px(26, 11, D.GRY[6])
-- nick in the left tip
c:fillMask(c:ellipse(8, 31, 2, 2), D.GRY[1])
c:px(12, 40, D.GRY[5]) c:px(15, 36, D.GRY[5]) c:px(12, 37, D.GRY[6]) c:px(14, 41, D.GRY[4])
D.fin()
