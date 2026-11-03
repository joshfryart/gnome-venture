-- ico-bird first draft (Sonnet). quirk: a pink worm dangling from its beak
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-bird"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

D.lit(c:poly{{18,30},{6,37},{8,43},{21,41}}, D.DBRN, 1.5)
D.fill(c:rect(26,44,27,52), GO[3]) D.fill(c:rect(33,44,34,52), GO[3])
D.fill(c:rect(23,52,28,53), GO[2]) D.fill(c:rect(30,52,35,53), GO[2])
local body = B.ell(30,34,14,12.5) body:add(B.ell(40,24,8,7.5)) D.lit(body, W, 5)
D.lit(B.ell(33,38,9,8), D.CREAM, 3)
D.lit(B.ell(24,33,8,5.5,0.4), D.DBRN, 2.5)
D.ln(c,19,31,28,36,D.DBRN[1]) D.ln(c,21,34,29,38,D.DBRN[1])
D.lit(c:poly{{47,21},{55,25},{47,29}}, GO, 1.2)
c:eyeSmall(42,20) c:cheek(39,27)
D.lit(c:line({{52,28},{53,33},{51,37},{53,40}}, 2), PE, 1)
D.fin()
