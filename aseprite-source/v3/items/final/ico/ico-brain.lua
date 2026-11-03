-- ico-brain first draft (Sonnet). quirk: a tiny gold spark of an idea above it
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-brain"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

local m = B.ell(23,31,11,13) m:add(B.ell(41,31,11,13)) m:add(B.ell(32,23,13,9)) m:add(B.ell(32,40,11,8))
m:add(c:poly{{29,46},{35,46},{36,57},{30,57}})
D.lit(m, PE, 5)
for y = 15, 44 do c:px(32,y,PE[1]) c:px(31,y+((y%4<2) and 0 or 0),PE[2]) end
local pls = { {{16,27},{20,24},{24,27},{27,24}}, {{14,36},{19,34},{23,38},{27,34}}, {{37,24},{41,27},{45,24},{49,27}}, {{37,34},{41,38},{45,34},{50,36}}, {{22,19},{26,17},{30,20}}, {{34,20},{38,17},{42,19}}, {{21,43},{26,41},{29,44}}, {{35,44},{38,41},{43,43}} }
for _, p in ipairs(pls) do D.poly(c, p, PE[2], m) end
for _, p in ipairs(pls) do for i = 1, #p-1 do D.ln(c, p[i][1], p[i][2]-1, p[i+1][1], p[i+1][2]-1, PE[5], m) end end
c:sparkle(52,10) c:px(52,10,GO[6]) for _, p in ipairs{{52,9},{52,11},{51,10},{53,10}} do c:px(p[1],p[2],GO[4]) end
D.fin()
