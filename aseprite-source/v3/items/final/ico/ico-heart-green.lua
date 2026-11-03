local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-heart-green: leafy green heart with a leaf vein. quirk: a tiny sprout with two leaves pops out of the cleft.
local c = D.new("ico-heart-green")
local h = D.heart(32, 33, 20)
D.lit(h, D.GREEN, 9, { amb = 0.06 })
D.ln(32, 24, 32, 46, D.GREEN[2]) 
D.ln(32, 30, 24, 26, D.GREEN[2]) D.ln(32, 30, 40, 26, D.GREEN[2]) D.ln(32, 38, 25, 33, D.GREEN[2]) D.ln(32, 38, 39, 33, D.GREEN[2])
D.fill(D.rect(19, 21, 22, 22), D.GREEN[6]) D.px(18, 23, D.GREEN[6])
D.fill(D.rect(32, 8, 33, 18), D.GREEN[2]) D.fill(D.rect(32, 9, 32, 18), D.GREEN[4])
D.lit(D.ell(27, 9, 5, 3, .5), D.GREEN, 2) D.lit(D.ell(38, 8, 5, 3, -.5), D.GREEN, 2)
D.fin()
