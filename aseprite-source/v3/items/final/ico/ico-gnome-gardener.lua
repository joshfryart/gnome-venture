local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-gnome-gardener: gnome face under a red hat, white beard, trowel at right. quirk: a daisy stuck on the hat tip.
local c = D.new("ico-gnome-gardener")
local SKIN = { "#9a4f45", "#c9786a", "#e69a82", "#f4b79a", "#ffd2b4", "#ffe6cf" }
-- trowel (behind)
D.lit(D.poly2({ { 52, 24 }, { 58, 33 }, { 52, 45 }, { 47, 33 } }), D.STEEL, 3)
D.fill(D.rect(52, 28, 52, 40), D.STEEL[2])
D.lit(D.c:line({ { 52, 45 }, { 52, 57 } }, 3), D.BRN, 1.5)
-- hat
local hat = D.poly2({ { 31, 6 }, { 44, 28 }, { 20, 28 } }):add(D.ell(36, 8, 4, 3))
D.lit(hat, D.RED, 5)
D.fill(D.rect(19, 25, 45, 28), D.RED[2]) D.fill(D.rect(20, 25, 44, 25), D.RED[5])
-- face
D.lit(D.ell(32, 33, 9, 5), SKIN, 3)
D.fill(D.rect(20, 28, 44, 28), D.RED[1])
-- beard
local beard = D.poly2({ { 21, 34 }, { 43, 34 }, { 32, 59 } }):add(D.ell(26, 38, 6, 5)):add(D.ell(38, 38, 6, 5))
beard:cut(D.rect(0, 0, 63, 33))
D.lit(beard, D.CREAM, 6, { amb = 0.12 })
D.fill(D.rect(26, 36, 26, 40), D.CREAM[3]) D.fill(D.rect(37, 38, 37, 44), D.CREAM[3])
D.lit(D.ell(32, 36, 3, 3), SKIN, 2, { amb = 0.05 })
D.fill(D.rect(31, 38, 33, 38), "#b85a52")
c:eyeSmall(26, 30) c:eyeSmall(37, 30)
-- daisy
for _, p in ipairs({ { 36, 3 }, { 36, 7 }, { 34, 5 }, { 38, 5 } }) do D.px(p[1], p[2], D.CR) end
D.px(36, 5, "#f2bb2e")
D.fin()
