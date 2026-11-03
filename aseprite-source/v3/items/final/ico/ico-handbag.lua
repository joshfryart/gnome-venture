local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-handbag: pink leather handbag with a tan handle arc and gold clasp. quirk: a little cream price tag dangling from the handle.
local c = D.new("ico-handbag")
local PK = { "#6e1e4a", "#a82c6a", "#d4408a", "#ee5aa0", "#ff8cc0", "#ffc0dc" }
D.lit(D.sub(D.ring(30, 31, 15, 11), D.rect(0, 30, 63, 63)), D.BRN, 1.5, { amb = 0.2 })
D.fill(D.sub(D.ring(30, 31, 15, 14), D.rect(0, 30, 63, 63)), D.BRN[5]) -- bright edge
local body = D.c:rrect(8, 28, 53, 55, 5)
D.lit(body, PK, 8, { amb = 0.08 })
-- flap
local flap = D.poly2({ { 8, 28 }, { 53, 28 }, { 53, 36 }, { 32, 44 }, { 8, 36 } }):clip(body)
D.lit(flap, PK, 5, { amb = 0.2 })
D.ln(8, 36, 32, 44, PK[1]) D.ln(32, 44, 53, 36, PK[1])
c:stitch({ { 12, 31 }, { 49, 31 } })
-- clasp
D.lit(D.c:rrect(28, 38, 36, 46, 2), D.GOLD, 3)
D.fill(D.rect(31, 41, 33, 43), D.GOLD[1]) D.px(29, 39, D.GOLD[6])
-- tag
D.ln(17, 24, 15, 31, D.CREAM[2])
D.lit(D.rect(11, 31, 18, 38), D.CREAM, 2, { amb = 0.2 }) D.px(14, 34, D.INK) D.px(15, 34, D.INK) D.px(14, 36, D.RED[3])
D.fin()
