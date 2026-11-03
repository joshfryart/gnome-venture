-- ico-bone first draft (Sonnet). quirk: a bite taken out of one end
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-bone"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

local m = c:line({{20,44},{44,20}}, 6)
for _, p in ipairs{{21,49},{15,43},{49,21},{43,15}} do m:add(B.ell(p[1],p[2],4.7,4.7)) end
m:cut(B.ell(52,17,3.2,3.2))
D.lit(m, D.CREAM, 3.5)
D.ln(c,25,43,43,25,D.CREAM[2]) D.ln(c,26,44,44,26,D.CREAM[1])
c:px(53,19,D.CREAM[3]) c:px(55,21,D.CREAM[2])
c:px(56,17,D.CREAM[4])
D.fin()
