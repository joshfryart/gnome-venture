local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-house-row: two neighbour houses, a small orange one and a tall cream one with a purple roof. quirk: a cat dozes on the small roof.
local c = D.new("ico-house-row")
c:groundShadow(32, 58, 26, 2)
-- tall house
D.lit(D.rect(29, 26, 57, 56), D.CREAM, 6, { amb = 0.1 })
for y = 31, 55, 5 do D.fill(D.rect(29, y, 57, y), D.CREAM[2]) end
D.lit(D.poly2({ { 25, 29 }, { 43, 7 }, { 61, 29 } }):add(D.rect(25, 28, 61, 30)), D.PURP, 7, { amb = 0.1 })
D.ln(43, 7, 25, 29, D.PURP[5]) D.fill(D.rect(25, 30, 61, 30), D.PURP[1])
D.lit(D.rect(35, 34, 44, 43), D.BLUE, 3) D.fill(D.rect(39, 34, 40, 43), D.BRN[3]) D.fill(D.rect(35, 38, 44, 39), D.BRN[3]) D.px(36, 35, D.CR)
D.lit(D.c:rrect(47, 42, 55, 56, 3):add(D.rect(47, 46, 55, 56)), D.BRN, 3) D.px(53, 50, D.GOLD[5])
-- small house (front)
D.lit(D.rect(5, 38, 28, 56), D.ORG, 5, { amb = 0.1 })
for y = 42, 54, 4 do D.fill(D.rect(5, y, 28, y), D.ORG[2]) end
D.lit(D.poly2({ { 2, 40 }, { 16, 24 }, { 31, 40 } }):add(D.rect(2, 39, 31, 41)), D.RED, 7, { amb = 0.1 })
D.ln(16, 24, 2, 40, D.RED[5]) D.fill(D.rect(2, 41, 31, 41), D.RED[1])
D.lit(D.c:rrect(10, 46, 16, 56, 2):add(D.rect(10, 50, 16, 56)), D.BRN, 2) D.px(15, 52, D.GOLD[5])
D.lit(D.rect(20, 45, 26, 51), D.BLUE, 2) D.px(21, 46, D.CR)
-- cat on roof
D.fill(D.ell(17, 25, 4, 2.4), D.CREAM[2]) D.fill(D.ell(12, 25, 2, 2), D.CREAM[2]) D.fill(D.rect(11, 22, 11, 23), D.CREAM[2]) D.fill(D.rect(13, 22, 13, 23), D.CREAM[2]) D.px(21, 24, D.CREAM[2]) D.px(22, 23, D.CREAM[2])
D.fin()
