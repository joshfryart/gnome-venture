local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-lantern: iron-capped glass lantern with a bright flame. quirk: a small moth bumps against the glass.
local c = D.new("ico-lantern")
D.lit(D.seg({{22,16},{22,8},{42,8},{42,16}}, 2), D.STEEL, 1)
D.lit(c:poly{{22,22},{42,22},{46,28},{18,28}}, D.STEEL, 2)
D.lit(c:rect(26, 14, 38, 22), D.STEEL, 1.5)
local gl = c:poly{{20,28},{44,28},{44,48},{20,48}}
D.cyl(gl, D.ORG, 20, 44)
D.fill(c:rect(24, 30, 25, 36), D.ORG[6])
D.lit(D.ell(32, 40, 4, 6), D.GOLD, 2)
D.fill(D.ell(32, 41, 2, 3), D.CR)
D.fill(c:rect(31, 28, 33, 48), D.STEEL[2]) D.fill(c:rect(19, 28, 20, 48), D.STEEL[2]) D.fill(c:rect(43, 28, 44, 48), D.STEEL[1])
D.lit(c:poly{{18,48},{46,48},{42,54},{22,54}}, D.STEEL, 2)
local moth = c:poly{{47,34},{54,30},{55,38},{47,38}}
D.lit(moth, D.CREAM, 1.5) D.px(46, 36, INK)
D.fin()
