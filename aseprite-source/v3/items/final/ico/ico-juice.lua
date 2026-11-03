local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-juice: tall tapered glass of orange juice, red straw, orange slice on the rim. quirk: a paper umbrella sticks out.
local c = D.new("ico-juice")
local g = c:poly{{16,22},{44,22},{40,56},{20,56}}
D.lit(g, "sea", 3)
local j = c:poly{{17,28},{43,28},{40,54},{20,54}}
D.cyl(j, D.ORG, 17, 43)
D.fill(c:rect(17, 28, 43, 28), D.ORG[6])
D.px(20, 32, "#e4f6ff") D.px(20, 33, "#e4f6ff") D.px(20, 34, "#e4f6ff") D.px(21, 31, "#e4f6ff")
D.lit(D.seg({{36,26},{44,8}}, 3), D.RED, 1)
D.fill(c:rect(36, 8, 36, 8), D.RED[6])
-- umbrella
D.lit(c:poly{{22,14},{34,6},{40,16},{30,18}}, D.PURP, 1.5)
D.px(31, 8, D.PURP[6]) D.px(32, 8, D.PURP[6])
D.ln(30, 17, 27, 26, D.BRN[4])
-- slice
local sl = D.ell(14, 24, 6, 6)
D.lit(sl, D.ORG, 3)
D.lit(D.ell(14, 24, 4, 4), D.ORG, 1.5)
D.ln(14, 20, 14, 28, D.ORG[6]) D.ln(10, 24, 18, 24, D.ORG[6])
D.fin()
