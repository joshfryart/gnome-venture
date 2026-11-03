-- ico-box first draft (Sonnet). quirk: two eyes peeking out of a cut-out hole
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-box"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

local WK = D.WICK
local L = c:poly{{10,22},{32,32},{32,54},{10,44}}
local R = c:poly{{32,32},{54,22},{54,44},{32,54}}
local T = c:poly{{32,10},{54,20},{32,30},{10,20}}
D.fill(L, WK[3]) D.fill(R, WK[2]) D.fill(T, WK[5])
D.ln(c,10,22,32,32,WK[4]) D.ln(c,10,23,32,33,WK[4]) D.ln(c,32,31,32,53,WK[1]) D.ln(c,33,32,54,22,WK[1]) D.ln(c,32,10,10,20,WK[6])
D.ln(c,32,10,54,20,WK[6]) D.ln(c,11,21,32,11,WK[6])
D.ln(c,12,44,30,53,WK[2])
-- tape on top (along the long diagonal) and down the left face
D.fill(c:poly{{29,15},{35,18},{35,28},{29,25}}, WK[4])
D.fill(c:poly{{26,28},{32,30},{32,32},{26,30}}, WK[4])
-- cut-out hole with eyes on the left face
local hole = c:poly{{15,35},{26,40},{26,47},{15,42}}
D.fill(hole, D.DKP[1])
D.fill(c:rect(17,38,19,40), D.CR) D.fill(c:rect(22,40,24,42), D.CR)
c:px(18,39,D.INK) c:px(23,41,D.INK)
-- label on the right face
D.fill(c:poly{{39,36},{48,32},{48,38},{39,42}}, D.CREAM[5])
D.ln(c,41,38,46,36,WK[2]) D.ln(c,41,40,46,38,WK[2])
D.fin()
