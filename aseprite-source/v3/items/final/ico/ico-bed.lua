-- ico-bed first draft (Sonnet). quirk: a little Z of sleep floating over the pillow
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-bed"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

D.lit(c:rect(9,45,53,49), W, 1.5)
D.lit(c:rect(10,49,13,54), W, 1) D.lit(c:rect(49,49,52,54), W, 1)
D.lit(c:rrect(15,36,48,45,3), D.CREAM, 2)
D.lit(c:rrect(8,12,15,50,2), W, 2) D.lit(B.ell(11.5,11,3.5,3.5), GO, 2)
D.lit(c:rrect(48,34,54,50,2), W, 2)
D.lit(c:rrect(26,33,48,45,4), SE, 2.5)
D.ln(c,30,38,46,38,SE[2]) D.ln(c,30,41,46,41,SE[2])
D.lit(B.ell(21,33,6.5,4), PE, 2)
local Zc = "#b6f0e0"
D.fill(c:rect(24,17,30,18), Zc) D.fill(c:rect(24,24,30,25), Zc)
for i = 0, 5 do D.fill(c:rect(29-i,18+i,30-i,19+i), Zc) end
D.fill(c:rect(35,10,38,10), Zc) D.fill(c:rect(35,13,38,13), Zc) D.fill(c:rect(37,11,37,11), Zc) D.fill(c:rect(36,12,36,12), Zc)
D.fin()
