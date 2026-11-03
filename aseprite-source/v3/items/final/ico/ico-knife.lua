local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-knife: kitchen knife on the diagonal with wooden handle and three rivets. quirk: a tiny radish slice stuck on the tip.
local c = D.new("ico-knife")
D.lit(D.seg({{10,54},{26,38}}, 6), "wood", 3)
D.lit(c:poly{{22,34},{52,6},{57,8},{47,28},{30,42}}, D.STEEL, 3)
D.ln(26, 34, 50, 10, D.STEEL[6])
D.ln(23, 35, 31, 43, D.GOLD[4]) D.ln(24, 35, 32, 43, D.GOLD[3])
for _, p in ipairs{{14,50},{18,46},{22,42}} do D.px(p[1], p[2], D.GOLD[5]) end
local rd = D.ell(54, 52, 5, 5) D.lit(rd, D.RED, 2.5)
D.lit(D.ell(54, 52, 2, 2), D.CREAM, 1)
D.fin()
