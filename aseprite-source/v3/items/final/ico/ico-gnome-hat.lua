local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-gnome-hat: floppy red pointed hat with cream brim, tip drooping to the right. quirk: a patched hole with gold stitching plus a tiny mushroom on the brim.
local c = D.new("ico-gnome-hat")
c:groundShadow(32, 57, 20, 2)
local cone = D.poly2({ { 14, 50 }, { 49, 50 }, { 43, 34 }, { 41, 22 }, { 50, 12 }, { 56, 14 }, { 45, 4 }, { 33, 14 }, { 25, 30 } })
D.lit(cone, D.RED, 6, { amb = 0.08 })
-- fold line
D.ln(34, 18, 44, 30, D.RED[2]) D.ln(34, 19, 43, 30, D.RED[2])
-- patch
local patch = D.rect(21, 36, 29, 44)
D.lit(patch, D.BLUE, 2, { amb = 0.1 })
c:stitch({ { 20, 35 }, { 30, 35 }, { 30, 45 }, { 20, 45 }, { 20, 35 } })
-- brim
local brim = D.ell(32, 51, 22, 5)
D.lit(brim, D.CREAM, 6, { amb = 0.1 })
D.fill(D.ell(32, 49, 15, 2):clip(brim), D.RED[1])
-- mushroom on brim
D.fill(D.rect(52, 50, 53, 53), D.CREAM[4])
D.lit(D.ell(52.5, 49, 4, 3), D.RED, 2) D.px(51, 48, D.CR)
D.fin()
