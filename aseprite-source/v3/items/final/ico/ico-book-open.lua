-- ico-book-open first draft (Sonnet). quirk: a pressed pink flower on the right page
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-book-open"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

D.lit(c:poly{{4,19},{31,23},{32,23},{60,19},{60,54},{32,57},{4,54}}, W, 2)
local pl = c:poly{{7,17},{20,14},{31,19},{31,50},{20,46},{7,49}}
D.lit(pl, D.CREAM, 3) D.lit(D.mirror(pl), D.CREAM, 3)
D.fill(c:rect(31,19,32,50), W[1])
for i = 0, 4 do local y = 21 + i * 5 D.ln(c,10,y,27,y+1,"#a8845e") D.ln(c,38,y,54,y-1+1,"#a8845e") end
D.fill(c:rect(42,28,49,35), D.CREAM[4])
D.lit(B.ell(45.5,31.5,3.5,3.5), PE, 1.5) c:px(45,31,GO[5]) c:px(46,31,GO[5]) c:px(45,32,GO[5])
c:px(11,25,D.CR)
D.fin()
