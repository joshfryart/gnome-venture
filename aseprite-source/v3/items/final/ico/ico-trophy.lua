local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-trophy: gold winner's cup with loop handles, stem and a dark wood plinth.
-- quirk: a red ribbon bow is tied round the left handle.
local c = D.new("ico-trophy")
D.lit(c, c:rrect(18, 47, 46, 57, 2), D.WOOD, 3)
c:fillMask(c:rect(26, 51, 38, 53), D.GOLD[4])
D.lit(c, c:rect(28, 38, 36, 47), D.GOLD, 3)
D.lit(c, c:rrect(23, 43, 41, 48, 2), D.GOLD, 2)
for _, sx in ipairs{ -1, 1 } do
  local h = c:ellipse(32 + sx * 19, 20, 8, 9) h:cut(c:ellipse(32 + sx * 19, 20, 4, 5)):cut(c:rect(32 - sx * 6 + (sx > 0 and 0 or -16), 4, 32 - sx * 6 + (sx > 0 and 16 or 0), 36))
  D.lit(c, h, D.GOLD, 2)
end
local cup = c:poly{ {14, 6}, {50, 6}, {47, 24}, {40, 36}, {24, 36}, {17, 24} }
cup:add(c:ellipse(32, 6, 18, 2))
D.lit(c, cup, D.GOLD, 8, { amb = 0.05 })
c:fillMask(D.star(c, 32, 20, 8, 3, 5), D.YEL[6])
c:fillMask(D.star(c, 32, 20, 5, 2, 5), D.GOLD[5])
c:fillMask(c:rect(20, 9, 22, 20), D.GOLD[6])
D.lit(c, c:ellipse(11, 24, 3, 2), D.RED, 2) D.lit(c, c:ellipse(18, 24, 3, 2), D.RED, 2)
D.lit(c, c:poly{ {13, 25}, {16, 25}, {13, 31}, {10, 31} }, D.RED, 2)
D.fin()
