-- ico-monkey first draft (Sonnet). quirk: a banana is tucked on its head like a hat
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-monkey")
local FUR = D.rp("wood")
local TAN = D.rp("skinA")
-- ears
for _, e in ipairs{ {13, 33}, {51, 33} } do D.lit(D.ell(e[1], e[2], 6, 6), FUR, 3) D.fill(D.ell(e[1] + (e[1] < 30 and 1 or -1), e[2], 3, 3), TAN[3]) end
-- head
D.lit(D.ell(32, 30, 17, 16), FUR, 8)
-- face mask (two lobes + muzzle)
local face = D.ell(25, 31, 7, 7):add(D.ell(39, 31, 7, 7)):add(D.ell(32, 38, 11, 9)):add(c:rect(26, 28, 38, 36))
D.lit(face, TAN, 5, { amb = .12 })
-- eyes
c:eyeSmall(24, 26) c:eyeSmall(37, 26)
-- nostrils and mouth
D.fill(c:rect(29, 36, 30, 37), D.INK) D.fill(c:rect(34, 36, 35, 37), D.INK)
D.fill(c:rect(28, 41, 36, 41), "#7a4036") D.fill(c:rect(27, 40, 27, 40), "#7a4036") D.fill(c:rect(37, 40, 37, 40), "#7a4036")
D.fill(c:rect(30, 42, 34, 43), "#e8493b") 
c:cheek(21, 38) c:cheek(40, 38)
-- body hint + chin tuft
D.lit(D.ell(32, 51, 11, 6), FUR, 2)
-- banana hat
local ban = c:line({ {18, 14}, {26, 10}, {38, 10}, {46, 15} }, 4)
D.lit(ban, D.GOLD, 2.5)
D.fill(c:rect(17, 13, 19, 15), "#6f4033") D.fill(c:rect(45, 14, 47, 16), "#6f4033")
c:px(26, 10, CR) c:px(27, 10, CR)
D.fin()
