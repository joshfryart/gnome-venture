local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-id-card: blue ID card with a gnome photo, text lines and a red seal. quirk: the photo gnome's hat tip pokes out over the photo frame.
local c = D.new("ico-id-card")
local card = D.c:rrect(7, 10, 56, 54, 5)
D.lit(card, D.BLUE, 9, { amb = 0.1 })
D.fill(D.rect(10, 13, 53, 13), D.BLUE[5])
-- punch slot
D.fill(D.c:rrect(26, 11, 37, 14, 1), D.BLUE[1])
-- photo
D.lit(D.rect(12, 20, 29, 40), D.CREAM, 3, { amb = 0.2 })
D.lit(D.ell(20.5, 31, 5, 5), { "#9a4f45", "#c9786a", "#e69a82", "#f4b79a", "#ffd2b4", "#ffe6cf" }, 3)
D.lit(D.poly2({ { 21, 14 }, { 27, 27 }, { 14, 27 } }), D.RED, 3)
D.fill(D.rect(14, 38, 27, 40), D.CREAM[1])
D.lit(D.poly2({ { 15, 38 }, { 26, 38 }, { 20, 43 } }), D.CREAM, 3)
D.px(18, 31, D.INK) D.px(23, 31, D.INK)
-- lines
D.fill(D.rect(34, 22, 50, 24), D.CREAM[5]) D.fill(D.rect(34, 29, 47, 30), D.CREAM[4]) D.fill(D.rect(34, 34, 50, 35), D.CREAM[4]) D.fill(D.rect(34, 39, 43, 40), D.CREAM[4])
-- seal
D.lit(D.disc(46, 46, 4), D.RED, 4) D.px(44, 44, D.CR)
D.fill(D.rect(14, 46, 30, 47), D.GOLD[4])
D.fin()
