local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-graduation: navy mortarboard on a skull cap with a gold tassel. quirk: the tassel is tangled in a loop and a pencil is tucked behind the board.
local c = D.new("ico-graduation")
local NAVY = { "#161a3a", "#242c5e", "#34408a", "#4a5aa8", "#6c7cc8", "#a0aef0" }
local capb = D.poly2({ { 17, 32 }, { 47, 32 }, { 47, 46 }, { 40, 52 }, { 24, 52 }, { 17, 46 } })
D.lit(capb, NAVY, 6, { amb = 0.1 })
D.fill(D.rect(17, 32, 47, 34), NAVY[1])
local board = D.poly2({ { 32, 12 }, { 59, 25 }, { 32, 37 }, { 5, 25 } })
D.lit(board, NAVY, 7, { amb = 0.12, wrap = 0.3 })
D.ln(32, 12, 59, 25, NAVY[5]) D.ln(32, 12, 5, 25, NAVY[6])
D.ln(5, 25, 32, 37, NAVY[1]) D.ln(59, 25, 32, 37, NAVY[1])
-- button
D.lit(D.disc(32, 25, 3), D.GOLD, 2)
-- tassel
D.ln(33, 26, 48, 28, D.GOLD[4]) D.ln(33, 27, 48, 29, D.GOLD[3])
D.ln(48, 29, 49, 38, D.GOLD[3]) D.ln(49, 29, 50, 38, D.GOLD[4])
D.fill(D.ring(49, 40, 4, 2), D.GOLD[4]) -- tangle loop
D.lit(D.poly2({ { 46, 42 }, { 53, 42 }, { 54, 54 }, { 45, 54 } }), D.GOLD, 3)
D.fill(D.rect(46, 43, 53, 43), D.GOLD[1]) D.px(47, 46, D.GOLD[6]) D.px(47, 50, D.GOLD[2])
-- pencil
D.fill(D.c:line({ { 12, 26 }, { 20, 22 } }, 2), D.GOLD[5]) D.px(11, 27, D.INK) D.px(20, 22, "#ff8cb4")
D.fin()
