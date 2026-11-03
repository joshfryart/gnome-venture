local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-curry: red ceramic bowl brimming with golden curry, a carrot and potato chunk, a spoon, steam.
-- quirk: a tiny red chili lies across the rim.
local c = D.new("ico-curry")
c:groundShadow(32, 56, 22, 3)
local bowl = D.isect(D.ell(32, 36, 24, 20), c:rect(0, 36, 63, 60))
D.lit(bowl, D.RED, 10)
D.fill(c:rect(10, 44, 54, 44), D.RED[2])
D.px(18, 42, D.RED[6]) D.px(19, 42, D.RED[6]) D.px(17, 43, D.RED[5])
D.fill(D.isect(bowl, c:rect(0, 52, 63, 53)), D.RED[2])
-- surface
local sur = D.ell(32, 36, 23, 8)
D.lit(sur, D.ORG, 6, {})
D.fill(D.ell(34, 36, 17, 5), "#c26a24")
D.lit(D.ell(24, 35, 4, 3), D.ORG, 2) -- carrot
D.fill(c:rect(23, 34, 24, 35), D.ORG[6])
D.lit(D.ell(38, 37, 4, 3), D.CREAM, 2) -- potato
D.lit(D.ell(30, 38, 2.5, 1.8), D.GREEN, 1.5) -- pea/leaf
D.fill(c:rect(23, 32, 25, 32), D.ORG[6])
-- spoon
D.fill(c:line({ { 44, 30 }, { 56, 12 } }, 2), D.STEEL[4])
D.lit(D.ell(43, 32, 4, 2.6, -0.8), D.STEEL, 2)
-- chili
D.fill(c:line({ { 10, 34 }, { 16, 31 }, { 22, 31 } }, 3), D.RED[3]) D.px(9, 33, D.GREEN[3]) D.px(8, 32, D.GREEN[3]) D.px(11, 31, D.RED[6])
-- steam
for _, s in ipairs{ { 26, 22 }, { 36, 20 } } do D.fill(c:line({ { s[1], s[2] }, { s[1] + 3, s[2] - 4 }, { s[1], s[2] - 8 }, { s[1] + 3, s[2] - 12 } }, 2), D.CREAM[5]) end
D.fin()
