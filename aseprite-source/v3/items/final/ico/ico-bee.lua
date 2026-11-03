-- ico-bee first draft (Sonnet). quirk: pollen ball on one back leg
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-bee"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

D.lit(B.ell(21,27,8.5,4,-0.6), SE, 1.5) D.lit(B.ell(43,27,8.5,4,0.6), SE, 1.5)
D.fill(c:rect(28,45,29,50), D.MEM[1]) D.fill(c:rect(34,45,35,50), D.MEM[1])
local body = B.ell(32,38,9,12) D.lit(body, GO, 3.5)
for _, y in ipairs{34,35,41,42} do for x = 22, 42 do if body:has(x, y) then c:px(x, y, x <= 36 and "#46367a" or "#2a1f4d") end end end
D.fill(c:rect(31,51,33,52), D.MEM[1]) c:px(32,53,D.MEM[1])
D.lit(B.ell(32,22,7.5,6.5), GO, 3)
D.ln(c,28,17,25,9,D.MEM[2]) D.ln(c,29,17,26,9,D.MEM[2]) D.ln(c,36,17,39,9,D.MEM[2]) D.ln(c,35,17,38,9,D.MEM[2])
D.lit(B.ell(25,8,2.5,2.5), GO, 1) D.lit(B.ell(39,8,2.5,2.5), GO, 1)
c:eyeSmall(28,20) c:eyeSmall(35,20) c:cheek(25,25) c:cheek(38,25)
c:px(31,26,D.MEM[1]) c:px(32,26,D.MEM[1])
D.lit(B.ell(20,45,3.5,3.5), D.ORG, 2) c:px(18,44,D.CR)
D.ln(c,25,46,21,46,D.MEM[2])
D.fin()
