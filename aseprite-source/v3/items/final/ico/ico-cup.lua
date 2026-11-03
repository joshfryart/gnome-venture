local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-cup: round blue-and-cream porcelain teacup on a saucer, tea inside, steam curl.
-- quirk: a tea-bag tag on a string hangs over the rim.
local c = D.new("ico-cup")
D.lit(D.ell(30, 52, 22, 5), D.CREAM, 3)
D.fill(c:rect(14, 53, 46, 54), D.CREAM[2])
local body = c:poly{ { 10, 28 }, { 50, 28 }, { 46, 44 }, { 38, 50 }, { 22, 50 }, { 14, 44 } }
D.lit(body, D.CREAM, 7)
-- handle
D.lit(D.ring(51, 36, 8, 4):cut(c:rect(0, 0, 47, 63)), D.CREAM, 2)
-- blue band
D.fill(D.isect(body, c:rect(0, 36, 63, 39)), D.BLUE[3]) D.fill(D.isect(body, c:rect(0, 39, 63, 40)), D.BLUE[2])
for x = 14, 46, 6 do D.px(x, 43, D.BLUE[4]) D.px(x + 1, 44, D.BLUE[4]) end
-- rim + tea
D.lit(D.ell(30, 28, 20, 5), D.CREAM, 3)
D.fill(D.ell(30, 29, 17, 3.5), "#8a4a26") D.fill(D.ell(29, 29, 12, 2), "#b8702f")
D.px(22, 28, D.CR) D.px(23, 28, D.CR)
-- tag + string
D.fill(c:line({ { 38, 29 }, { 44, 22 } }, 1), D.INK)
D.fill(c:rect(43, 16, 48, 23), D.RED[4]) D.px(44, 17, D.CR) D.px(44, 18, D.CR)
-- steam
D.fill(c:line({ { 24, 20 }, { 27, 15 }, { 24, 10 }, { 27, 5 } }, 2), D.CREAM[5])
D.fin()
