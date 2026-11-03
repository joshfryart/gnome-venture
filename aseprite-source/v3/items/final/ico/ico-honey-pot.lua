local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-honey-pot: round amber honey jar with a wooden lid and a drip. quirk: a bee has landed on the lid.
local c = D.new("ico-honey-pot")
c:groundShadow(32, 58, 20, 2)
local jar = D.c:rrect(12, 24, 52, 57, 12)
D.lit(jar, D.ORG, 12, { amb = 0.1 })
D.fill(D.ell(20, 36, 2, 7):clip(jar), D.ORG[6]) D.px(19, 43, D.ORG[5])
-- label
D.lit(D.c:rrect(21, 36, 43, 50, 3), D.CREAM, 3, { amb = 0.2 })
local hx = { { 27, 41 }, { 32, 41 }, { 37, 41 }, { 29.5, 46 }, { 34.5, 46 } }
for _, h in ipairs(hx) do D.fill(D.ring(h[1], h[2], 2.6, 1), D.GOLD[3]) end
-- drip
D.fill(D.rect(14, 22, 21, 27), D.GOLD[4]) D.fill(D.rect(16, 27, 19, 33), D.GOLD[4]) D.fill(D.disc(17.5, 35, 2), D.GOLD[4]) D.px(16, 34, D.GOLD[6])
-- lid
D.lit(D.c:rrect(11, 14, 53, 24, 3), D.BRN, 4)
D.fill(D.rect(13, 15, 51, 15), D.BRN[5]) D.fill(D.rect(11, 23, 53, 23), D.BRN[1])
D.fill(D.rect(16, 18, 18, 18), D.BRN[2]) D.fill(D.rect(30, 20, 36, 20), D.BRN[2])
-- bee
D.fill(D.ell(44, 11, 4, 3), D.GOLD[4]) D.fill(D.rect(43, 8, 43, 13), D.INK) D.fill(D.rect(46, 9, 46, 12), D.INK)
D.fill(D.rect(48, 10, 49, 11), D.INK) D.fill(D.ell(42, 6, 2, 2), D.CR) D.fill(D.ell(46, 6, 2, 2), D.CR)
D.fin()
