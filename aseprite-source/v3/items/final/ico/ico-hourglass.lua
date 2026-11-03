local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-hourglass: wooden-framed hourglass with golden sand halfway down. quirk: a stray sand grain hops out of the lower bulb.
local c = D.new("ico-hourglass")
c:groundShadow(32, 60, 20, 2)
local GL = { "#5a8ab0", "#8ec0dc", "#b8e0f0", "#d4f0fa", "#e8f8fc", "#f8fdfe" }
D.lit(D.rect(14, 51, 17, 58), D.BRN, 1.5) D.lit(D.rect(47, 51, 50, 58), D.BRN, 1.5)
D.lit(D.rect(14, 6, 17, 13), D.BRN, 1.5) D.lit(D.rect(47, 6, 50, 13), D.BRN, 1.5)
local glass = D.poly2({ { 19, 12 }, { 45, 12 }, { 45, 17 }, { 35, 29 }, { 35, 35 }, { 45, 47 }, { 45, 52 }, { 19, 52 }, { 19, 47 }, { 29, 35 }, { 29, 29 }, { 19, 17 } })
D.lit(glass, GL, 12, { amb = 0.15 })
-- sand upper (lower part of top bulb)
D.fill(D.poly2({ { 24, 22 }, { 40, 22 }, { 33, 29 }, { 31, 29 } }):clip(glass), D.GOLD[4]) D.fill(D.rect(25, 22, 39, 22), D.GOLD[6])
-- stream
D.fill(D.rect(31, 29, 32, 46), D.GOLD[4]) D.px(31, 33, D.GOLD[6])
-- sand lower
D.fill(D.poly2({ { 21, 51 }, { 43, 51 }, { 35, 41 }, { 29, 41 } }):clip(glass), D.GOLD[4]) D.fill(D.poly2({ { 33, 41 }, { 43, 51 }, { 36, 51 } }):clip(glass), D.GOLD[2]) D.fill(D.rect(30, 41, 32, 42), D.GOLD[6])
-- glass glint
D.fill(D.rect(21, 14, 22, 18), D.CR) D.fill(D.rect(21, 48, 22, 50), D.CR)
-- plates
D.lit(D.c:rrect(11, 6, 53, 12, 2), D.BRN, 3) D.fill(D.rect(13, 7, 51, 7), D.BRN[5])
D.lit(D.c:rrect(11, 52, 53, 58, 2), D.BRN, 3) D.fill(D.rect(13, 53, 51, 53), D.BRN[5])
-- stray grains
D.fill(D.rect(48, 45, 49, 46), D.GOLD[4]) D.fill(D.rect(53, 40, 53, 40), D.GOLD[5])
D.fin()
