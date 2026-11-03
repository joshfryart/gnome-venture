local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-home: little cottage, red roof, round-top door, one window. quirk: a smoke curl from the chimney forms a tiny heart.
local c = D.new("ico-home")
c:groundShadow(32, 57, 22, 2)
D.lit(D.rect(43, 12, 49, 26), D.STEEL, 2, { amb = 0.15 }) D.fill(D.rect(42, 10, 50, 12), D.STEEL[2])
D.px(43, 10, D.STEEL[5])
D.lit(D.rect(14, 30, 50, 56), D.CREAM, 6, { amb = 0.1 })
for y = 34, 54, 5 do D.fill(D.rect(14, y, 50, y), D.CREAM[2]) end
D.lit(D.poly2({ { 6, 33 }, { 32, 8 }, { 58, 33 } }):add(D.rect(6, 31, 58, 33)), D.RED, 8, { amb = 0.08 })
D.ln(32, 8, 6, 33, D.RED[5]) D.fill(D.rect(6, 33, 58, 33), D.RED[1])
-- door
D.lit(D.c:rrect(22, 40, 32, 56, 4):add(D.rect(22, 44, 32, 56)), D.BRN, 3)
D.fill(D.rect(24, 42, 24, 55), D.BRN[5]) D.px(30, 49, D.GOLD[5])
-- window
D.lit(D.rect(37, 38, 46, 47), D.BLUE, 3)
D.fill(D.rect(41, 38, 42, 47), D.BRN[3]) D.fill(D.rect(37, 42, 46, 43), D.BRN[3]) D.px(38, 39, D.CR)
D.fill(D.rect(36, 48, 47, 49), D.BRN[2])
-- smoke heart
D.fill(D.heart(51, 4, 2.2), D.CREAM[5])
D.fin()
