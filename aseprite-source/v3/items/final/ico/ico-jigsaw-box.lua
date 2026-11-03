local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-jigsaw-box: blue puzzle box lid with a picture, one loose piece beside it. quirk: the loose piece is the missing sun.
local c = D.new("ico-jigsaw-box")
D.lit(c:rect(8, 14, 46, 50), D.BLUE, 3)
D.fill(c:rect(11, 17, 43, 47), D.GREEN[4]) D.fill(c:rect(11, 17, 43, 33), "#8bc4ea")
D.lit(c:poly{{11,47},{11,36},{22,28},{34,40},{43,32},{43,47}}, D.GREEN, 3)
D.lit(c:poly{{26,47},{33,36},{43,30},{43,47}}, "moss", 2)
D.fill(c:rect(11, 17, 43, 17), D.BLUE[6])
D.fill(c:rect(33, 20, 43, 29), "#8bc4ea")  -- sun hole
for _, p in ipairs{{29,17,33,17},{33,17,33,20},{33,20,43,20},{43,20,43,20}} do end
D.fill(c:rect(33,18,34,29), D.BLUE[4])
D.lit(c:rect(33, 30, 43, 31), D.BLUE, 1)
-- loose piece with knobs
local pc = c:rect(42, 36, 56, 50):add(D.ell(49, 34, 3, 3)):add(D.ell(58, 43, 3, 3)):cut(D.ell(40, 43, 3, 3))
D.lit(pc, D.GOLD, 2.5)
D.fill(c:rect(46, 40, 52, 46), D.GOLD[5])
D.fin()
