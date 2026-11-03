local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-tier-expert: purple shield with a thick gold rim and a big faceted gem.
-- quirk: the gem has a sparkle and a hairline facet crack of light.
local c = D.new("ico-tier-expert")
local sh = c:poly{ {12, 8}, {52, 8}, {52, 34}, {32, 58}, {12, 34} }
D.lit(c, sh, D.GOLD, 5)
local inn = c:poly{ {16, 12}, {48, 12}, {48, 33}, {32, 52}, {16, 33} }
D.lit(c, inn, D.PURP, 6)
local gem = c:poly{ {32, 17}, {42, 29}, {32, 46}, {22, 29} }
D.lit(c, gem, D.PINK, 4)
c:fillMask(c:poly{ {32, 17}, {42, 29}, {32, 29} }, D.PINK[5])
c:fillMask(c:poly{ {22, 29}, {32, 29}, {32, 46} }, D.PINK[3])
c:fillMask(c:rect(22, 29, 42, 29), D.PINK[6])
c:fillMask(c:rect(32, 30, 32, 45), D.PINK[2])
c:sparkle(25, 22)
D.fin()
