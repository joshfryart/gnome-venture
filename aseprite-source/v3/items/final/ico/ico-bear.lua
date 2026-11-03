-- ico-bear first draft (Sonnet). quirk: a gold-stitched pink patch sewn on the belly
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-bear"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

for _, e in ipairs{{22,13,4.5},{42,13,4.5}} do D.lit(B.ell(e[1],e[2],e[3],e[3]), DU, 2) D.fill(B.ell(e[1],e[2]+.5,2,2), PE[3]) end
D.lit(B.ell(19,40,4,6.5,0.4), DU, 2) D.lit(B.ell(45,40,4,6.5,-0.4), DU, 2)
D.lit(B.ell(24,55,5.5,4), DU, 2) D.lit(B.ell(40,55,5.5,4), DU, 2)
D.lit(B.ell(32,43,11,12), DU, 4)
local pt = c:rect(28,41,36,49) D.lit(pt, PE, 1.5, {amb=.2})
c:stitch({{27,40},{37,40},{37,50},{27,50},{27,40}})
D.lit(B.ell(32,22,12,10.5), DU, 5)
D.lit(B.ell(32,26.5,5.5,4), D.CREAM, 2)
D.fill(c:rect(30,24,33,26), D.INK) c:px(30,24,D.CR)
D.fill(c:rect(31,27,32,28), D.INK) c:px(30,28,D.INK) c:px(33,28,D.INK)
c:eyeSmall(25,18) c:eyeSmall(38,18)
c:cheek(22,24) c:cheek(40,24)
D.fin()
