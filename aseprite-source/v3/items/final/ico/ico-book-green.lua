-- ico-book-green first draft (Sonnet). quirk: a red bookmark ribbon dangling from the bottom
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-book-green"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

D.lit(c:rect(39,52,41,59), D.RED, 1)
D.lit(c:rect(45,12,50,52), D.CREAM, 1.5) for _, x in ipairs{47,49} do for y = 13, 51 do c:px(x,y,D.CREAM[2]) end end
D.lit(c:rrect(14,9,45,54,2), D.GREEN, 3.5)
D.lit(c:rect(14,10,19,53), D.GREEN, 1.5)
for y = 10, 53 do c:px(20,y,D.GREEN[1]) end
D.lit(c:rrect(24,18,38,26,1), GO, 1.5) D.ln(c,26,22,36,22,GO[2])
D.lit(B.ell(31,40,4,4), MO, 2)
D.ln(c,31,37,31,43,MO[1])
D.fin()
