local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-heart-yellow: golden heart that shines with a little star. quirk: a floating halo ring above it.
local c = D.new("ico-heart-yellow")
local h = D.heart(32, 36, 19)
D.lit(h, D.GOLD, 9, { amb = 0.06 })
D.fill(D.ell(23, 28, 4, 2.5, -.6):clip(h), D.GOLD[6])
D.px(41, 34, D.GOLD[2]) D.px(40, 40, D.GOLD[2]) D.px(33, 49, D.GOLD[1])
-- halo
D.fill(D.sub(D.ell(32, 8, 9, 3), D.ell(32, 8, 5, 1)), D.GOLD[5])
D.px(24, 8, D.GOLD[3]) D.px(40, 8, D.GOLD[3])
c:sparkle(50, 20)
D.fin()
