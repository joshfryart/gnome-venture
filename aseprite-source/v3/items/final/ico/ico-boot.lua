-- ico-boot first draft (Sonnet). quirk: a striped sock cuff peeking from the top
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-boot"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

local bt = c:poly{{17,13},{35,13},{35,34},{44,36},{52,42},{54,48},{54,54},{17,54}}
D.lit(bt, W, 3.5)
D.lit(c:poly{{17,49},{54,49},{54,55},{17,55}}, D.DBRN, 1.5)
D.fill(c:rect(17,49,26,55), W[1]) D.fill(c:rect(17,54,54,55), W[1])
D.lit(c:rect(16,6,36,13), D.CREAM, 2)
for _, x in ipairs{19,25,31} do D.fill(c:rect(x,6,x+2,13), PE[3]) end
D.ln(c,36,38,44,41,D.CREAM[4]) D.ln(c,36,42,44,45,D.CREAM[4]) D.ln(c,38,36,38,36,D.CREAM[4])
for y = 34, 46 do if bt:has(26,y) and y%3==0 then c:px(26,y,W[2]) end end
c:px(20,20,D.CREAM[5]) c:px(21,20,D.CREAM[5])
D.fin()
