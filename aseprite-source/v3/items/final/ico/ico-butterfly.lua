local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-butterfly")
local CR, INK, ell = D.CR, D.INK, D.ell
-- ico-butterfly: wide orange wings with dark veins and big cream-ringed spots, slim dusk body, curled feelers.
-- quirk: a nibbled bite out of the right forewing.
local lu, ru = ell(21, 24, 13, 9, -0.6), ell(43, 24, 13, 9, 0.6)
local ll, rl = ell(24, 43, 8, 7, 0.5), ell(40, 43, 8, 7, -0.5)
ru:cut(ell(51, 16, 3.5, 3.5, 0))
D.lit(ll, D.ORG, 5) D.lit(rl, D.ORG, 5) D.lit(lu, D.ORG, 6) D.lit(ru, D.ORG, 6)
D.poly(c, { {30, 28}, {16, 17} }, D.ORG[1]) D.poly(c, { {34, 28}, {47, 20} }, D.ORG[1])
for _, p in ipairs{ {18, 26}, {45, 28}, {22, 44}, {42, 44} } do
  D.fill(ell(p[1], p[2], 3, 3, 0), D.INK); D.fill(ell(p[1], p[2], 2, 2, 0), "#fff4d6"); D.fill(c:rect(p[1] - 1, p[2] - 1, p[1], p[2]), "#ff9f3c")
end
D.lit(c:rect(29, 18, 34, 50), D.DKP, 1.5, { amb = 0.2 })
D.lit(c:ellipse(31.5, 17, 4, 4), D.MEM, 2.5)
D.poly(c, { {30, 14}, {28, 9}, {25, 7} }, INK) D.poly(c, { {33, 14}, {36, 9}, {39, 7} }, INK)
D.fill(c:rect(24, 6, 25, 7), "#ff9f3c") D.fill(c:rect(39, 6, 40, 7), "#ff9f3c")
D.px(30, 17, CR) D.px(33, 17, CR)
D.fin()
