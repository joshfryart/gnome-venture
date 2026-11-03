local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-goat: side-on white goat with curled horn and beard, facing right. quirk: chewing a pink flower.
local c = D.new("ico-goat")
local W = { "#6b5c7e", "#958aa8", "#c2b8d0", "#e6e0ec", "#f6f2f6", "#fffaf8" }
c:groundShadow(30, 57, 18, 2)
local hoof = D.BRN
for _, x in ipairs({ 14, 21, 33, 40 }) do
  D.lit(D.rect(x, 38, x + 3, 54), W, 1.5, { amb = 0.15 }) D.fill(D.rect(x, 52, x + 3, 55), D.BRN[2]) D.px(x, 52, D.BRN[4])
end
D.lit(D.ell(27, 34, 17, 9), W, 8, { amb = 0.1 })
D.px(14, 28, W[6]) D.px(15, 28, W[6])
-- neck + head
D.lit(D.poly2({ { 36, 24 }, { 44, 16 }, { 48, 26 }, { 40, 40 } }), W, 4)
D.lit(D.ell(47, 22, 7, 6), W, 3)
D.lit(D.ell(53, 26, 5, 4), W, 2, { amb = 0.15 })
D.fill(D.rect(56, 25, 57, 26), D.INK)
-- ear
D.lit(D.ell(40, 21, 4, 2, .5), D.BRN, 1)
-- horn
D.lit(D.c:line({ { 44, 17 }, { 41, 9 }, { 45, 4 }, { 50, 5 } }, 3), D.CREAM, 1.5, { amb = 0.1 })
D.fill(D.rect(42, 10, 44, 10), D.CREAM[2]) D.fill(D.rect(42, 13, 44, 13), D.CREAM[2])
c:eyeSmall(48, 18)
-- beard
D.lit(D.poly2({ { 50, 29 }, { 56, 29 }, { 52, 38 } }), W, 2)
-- flower
D.fill(D.rect(56, 28, 58, 31), D.GREEN[4]) 
for _, p in ipairs({ { 58, 30 }, { 57, 32 }, { 59, 32 } }) do D.fill(D.rect(p[1] - 1, p[2] - 1, p[1] + 1, p[2]), "#ff8cb4") end
D.px(58, 31, D.GOLD[4])
-- tail
D.fill(D.rect(8, 28, 10, 30), W[4])
D.fin()
