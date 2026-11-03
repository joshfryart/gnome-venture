local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-globe: bold blue globe with green continents on a gold stand. quirk: a tiny red flag planted on a continent.
local c = D.new("ico-globe")
c:groundShadow(32, 58, 13, 2)
D.fill(D.rect(28, 50, 35, 55), D.GOLD[2]) -- stem
D.lit(D.rect(20, 54, 43, 58), D.GOLD, 2)
local g = D.disc(32, 29, 21)
-- gold meridian ring (behind, left side) drawn after sphere
D.lit(g, D.BLUE, 15, { amb = 0.06 })
local land = D.ell(24, 22, 8, 6, -.4):add(D.ell(21, 29, 4, 4)):add(D.ell(40, 38, 8, 6, .5)):add(D.ell(45, 28, 3, 4)):add(D.ell(30, 44, 4, 3))
land:clip(g)
D.lit(land, D.GREEN, 4, { amb = 0.1 })
D.seam(c, land, D.sub(g, land), D.GREEN[1])
-- gold ring arc, left rim
D.fill(D.sub(D.ring(32, 29, 22, 20), D.rect(0, 0, 63, 9)):clip(D.rect(0, 0, 32, 63)), D.GOLD[3])
D.px(14, 22, D.GOLD[6]) D.px(13, 24, D.GOLD[5])
-- flag
D.ln(25, 12, 25, 22, D.BRN[2]) D.fill(D.poly2({ {26, 12}, {32, 14}, {26, 17} }), D.RED[4]) D.px(27, 13, D.RED[6])
D.px(20, 18, D.CR) D.px(21, 18, D.CR)
D.fin()
