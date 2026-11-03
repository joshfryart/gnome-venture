-- ico-bat first draft (Sonnet). quirk: a tiny pink bow on one ear
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-bat"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

local wl = c:poly{{30,26},{15,14},{4,22},{7,31},{12,27},{15,35},{20,30},{24,38},{29,33},{30,38}}
local wr = D.mirror(wl)
D.lit(wl, D.MEM, 3) D.lit(wr, D.MEM, 3)
for _, p in ipairs{{{14,15},{7,30}},{{14,15},{15,34}},{{14,15},{23,37}}} do
  D.ln(c, p[1][1], p[1][2], p[2][1], p[2][2], D.MEM[1], wl)
  D.ln(c, 63-p[1][1], p[1][2], 63-p[2][1], p[2][2], D.MEM[1], wr)
end
local bd = B.ell(31.5,33,5,8) D.lit(bd, D.DKP, 2.5)
local el = c:poly{{27,20},{25,11},{31,17}} D.lit(el, D.DKP, 1)
local er = D.mirror(el) D.lit(er, D.DKP, 1)
local hd = B.ell(31.5,22,6.5,5.5) D.lit(hd, D.DKP, 3)
D.fill(c:rect(29,21,30,22), D.RED[5]) D.fill(c:rect(33,21,34,22), D.RED[5])
c:px(30,28,D.CR) c:px(33,28,D.CR) c:px(30,27,D.CR) c:px(33,27,D.CR)
D.fill(c:rect(24,16,26,18), PE[3]) c:px(25,17,PE[1]) c:px(23,15,PE[5]) c:px(27,19,PE[5])
D.fin()
