local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-ladybird: red domed beetle from above, six dots, ink head, thick legs. quirk: one spot is a heart.
local c = D.new("ico-ladybird")
for _, l in ipairs{ {{18,26},{8,22}}, {{16,36},{6,38}}, {{20,46},{10,54}}, {{46,26},{56,22}}, {{48,36},{58,38}}, {{44,46},{54,54}} } do
  D.fill(c:line(l, 3), D.DKP and D.DKP[1] or INK) end
D.lit(D.seg({{26,12},{22,4}}, 2), D.PURP, 1) D.lit(D.seg({{38,12},{42,4}}, 2), D.PURP, 1)
local bod = D.ell(32, 36, 17, 19)
D.lit(bod, D.RED, 7)
D.fill(c:rect(31, 20, 32, 54), D.RED[1])
D.fill(c:rect(31, 20, 32, 20), D.RED[2])
for _, s in ipairs{ {22,30,3}, {42,30,3}, {23,42,3}, {41,43,3} } do D.fill(D.ell(s[1], s[2], s[3] - .5, s[3] - .5), D.RED[1]) end
D.fill(D.heart(33, 51, 3), D.RED[1])
D.px(25, 24, D.RED[6]) D.px(26, 24, D.RED[6]) D.px(25, 25, D.RED[6])
local hd = D.ell(32, 14, 8, 6) D.lit(hd, D.PURP, 3)
D.fill(D.ell(28, 13, 1.2, 1.2), D.CR) D.fill(D.ell(36, 13, 1.2, 1.2), D.CR)
D.fin()
