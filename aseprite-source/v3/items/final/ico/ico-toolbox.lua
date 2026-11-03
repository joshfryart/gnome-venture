local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-toolbox: red steel toolbox, grey carry handle, gold latch.
-- quirk: a daisy sticker on the front and a spanner tip poking out of the lid gap.
local c = D.new("ico-toolbox")
c:groundShadow(32, 57, 24, 2)
D.lit(c, c:line({ {17, 26}, {19, 14}, {45, 14}, {47, 26} }, 4), D.GRY, 2)
local sp = c:line({ {38, 25}, {49, 12} }, 4)
D.lit(c, sp, D.GRY, 2) D.lit(c, c:ellipse(51, 10, 4, 4), D.GRY, 2) c:fillMask(c:rect(51, 6, 52, 9), D.GRY[1])
D.lit(c, c:rrect(7, 31, 57, 54, 3), D.RED, 6)
D.lit(c, c:rrect(7, 24, 57, 33, 3), D.RED, 3)
c:fillMask(c:rect(8, 32, 56, 33), D.RED[1])
D.lit(c, c:rrect(27, 29, 37, 40, 2), D.GOLD, 2)
c:fillMask(c:rect(31, 33, 33, 36), D.GOLD[1])
D.fillcorner = nil
for _, p in ipairs{ {10, 36}, {53, 36}, {10, 50}, {53, 50} } do c:fillMask(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), D.GRY[4]) end
for _, a in ipairs{ {0,-3},{3,0},{0,3},{-3,0} } do c:fillMask(c:ellipse(16 + a[1], 44 + a[2], 2, 2), CREAM) end
c:fillMask(c:ellipse(16, 44, 2, 2), D.YEL[3])
D.fin()
