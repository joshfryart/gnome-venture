local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-goblin: grinning green goblin head with huge pointed ears and tusks. quirk: a gold hoop earring and a chipped left ear tip.
local c = D.new("ico-goblin")
local G = { "#1f4a2a", "#2f7a34", "#4fa03a", "#78c24a", "#a4de6a", "#d4f59a" }
D.lit(D.poly2({ { 18, 30 }, { 6, 20 }, { 8, 32 }, { 18, 42 } }), G, 3)
D.lit(D.poly2({ { 46, 30 }, { 58, 16 }, { 56, 32 }, { 46, 42 } }), G, 3)
D.fill(D.poly2({ { 12, 29 }, { 8, 25 }, { 9, 31 } }), "#d98a7a") D.fill(D.poly2({ { 51, 29 }, { 55, 23 }, { 54, 31 } }), "#d98a7a")
D.lit(D.ell(32, 35, 15, 15), G, 8, { amb = 0.08 })
-- brow ridge
D.fill(D.poly2({ { 19, 27 }, { 30, 31 }, { 30, 28 }, { 21, 24 } }), G[1]) D.fill(D.poly2({ { 45, 27 }, { 34, 31 }, { 34, 28 }, { 43, 24 } }), G[1])
-- eyes
D.fill(D.ell(25.5, 32.5, 4, 3), D.GOLD[4]) D.fill(D.ell(38.5, 32.5, 4, 3), D.GOLD[4])
D.fill(D.rect(25, 31, 26, 34), D.INK) D.fill(D.rect(38, 31, 39, 34), D.INK) D.px(24, 31, D.GOLD[6]) D.px(37, 31, D.GOLD[6])
-- nose
D.lit(D.ell(32, 39, 3, 3), G, 2, { amb = 0.05 }) D.px(31, 41, G[1]) D.px(33, 41, G[1])
-- mouth + tusks
D.fill(D.c:rrect(23, 45, 41, 50, 2), D.INK)
D.fill(D.poly2({ { 24, 45 }, { 28, 45 }, { 26, 41 } }), D.CREAM[5]) D.fill(D.poly2({ { 36, 45 }, { 40, 45 }, { 38, 41 } }), D.CREAM[5])
D.fill(D.rect(29, 46, 31, 47), D.CREAM[4]) D.fill(D.rect(34, 46, 36, 47), D.CREAM[4])
D.fill(D.rect(28, 49, 36, 50), "#c4484a")
-- earring
D.fill(D.ring(8, 36, 3, 1), D.GOLD[4]) D.px(7, 35, D.GOLD[6])
-- chip
D.fin()
