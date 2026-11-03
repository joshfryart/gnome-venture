local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-cat")
local CR, INK, ell = D.CR, D.INK, D.ell
-- ico-cat: sitting orange tabby, round head with pointed ears, cream muzzle and chest, tail curling up at the right.
-- quirk: a ball of yarn at its feet, thread looped round one paw.
c:groundShadow(32, 58, 20, 2)
D.lit(c:line({ {44, 52}, {54, 48}, {55, 38}, {51, 32} }, 4), D.FUR, 2)
D.lit(ell(32, 44, 14, 14, 0), D.FUR, 8, { amb = 0.1 })
D.lit(ell(32, 47, 7, 10, 0), D.CREAM, 5, { amb = 0.2 })
D.lit(c:poly{ {17, 22}, {19, 6}, {29, 14} }, D.FUR, 2) D.lit(c:poly{ {47, 22}, {45, 6}, {35, 14} }, D.FUR, 2)
D.fill(c:poly{ {19, 16}, {20, 10}, {25, 14} }, "#ffa6bd") D.fill(c:poly{ {45, 16}, {44, 10}, {39, 14} }, "#ffa6bd")
D.lit(ell(32, 25, 16, 12, 0), D.FUR, 8, { amb = 0.1 })
for x = 31, 33, 1 do D.rect(x, 14, x, 17, D.FUR[2]) end
D.rect(26, 15, 26, 17, D.FUR[2]) D.rect(38, 15, 38, 17, D.FUR[2])
D.lit(ell(32, 31, 6, 4, 0), D.CREAM, 3, { amb = 0.2 })
c:eyeSmall(23, 22) c:eyeSmall(39, 22)
D.fill(c:rect(30, 28, 33, 29), "#e86a8a"); D.px(30, 28, D.CR); D.px(31, 31, INK) D.px(33, 31, INK) D.px(32, 30, INK)
D.px(21, 29, "#f5809f") D.px(22, 29, "#f5809f") D.px(42, 29, "#f5809f") D.px(43, 29, "#f5809f")
D.rect(24, 54, 27, 56, D.CR) D.rect(37, 54, 40, 56, D.CR)
D.lit(c:ellipse(10, 52, 5, 5), D.PINK, 4)
D.poly(c, { {7, 50}, {12, 54} }, D.PINK[1]) D.poly(c, { {6, 53}, {13, 51} }, D.PINK[2])
D.poly(c, { {15, 53}, {24, 55} }, D.PINK[3])
D.fin()
