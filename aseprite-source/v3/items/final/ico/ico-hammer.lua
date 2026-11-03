local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-hammer: claw hammer, steel head on a wooden handle with red grip tape. quirk: a bent nail still stuck in the claw.
local c = D.new("ico-hammer")
c:groundShadow(32, 58, 7, 1)
D.lit(D.rect(28, 20, 34, 57), D.BRN, 3, { amb = 0.15 })
for y = 24, 54, 4 do D.px(30, y, D.BRN[2]) D.px(32, y + 1, D.BRN[2]) end
D.px(29, 24, D.BRN[6]) D.px(29, 25, D.BRN[6])
-- grip tape
D.lit(D.rect(28, 40, 34, 57), D.RED, 3, { amb = 0.15 })
for y = 42, 56, 4 do D.fill(D.rect(28, y, 34, y), D.RED[2]) end
D.fill(D.rect(29, 41, 29, 56), D.RED[5])
-- head
local head = D.c:rrect(10, 8, 40, 22, 2):add(D.poly2({ { 40, 9 }, { 54, 6 }, { 55, 10 }, { 40, 21 } }))
D.lit(head, D.STEEL, 6, { amb = 0.1 })
D.fill(D.rect(10, 8, 17, 22), D.STEEL[2]) D.fill(D.rect(17, 8, 17, 22), D.STEEL[1]) D.fill(D.rect(10, 9, 11, 21), D.STEEL[3])
D.fill(D.rect(12, 9, 16, 9), D.STEEL[5])
D.px(22, 10, D.CR) D.px(23, 10, D.CR) D.px(24, 10, D.CR)
D.ln(42, 19, 52, 9, D.STEEL[5])
D.fill(D.rect(26, 22, 36, 22), D.STEEL[1])
-- nail
D.ln(54, 11, 57, 22, D.STEEL[3]) D.ln(55, 11, 58, 22, D.STEEL[4]) D.fill(D.rect(52, 10, 56, 11), D.STEEL[4]) 
D.ln(57, 22, 54, 26, D.STEEL[3])
D.fin()
