-- ico-book-red first draft (Sonnet). quirk: a green leaf poking out as a bookmark
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-book-red"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

D.lit(B.ell(40,6,2.8,5.5,0.35), MO, 1.5) D.ln(c,38,10,42,2,MO[2])
D.lit(c:poly{{20,10},{50,13},{50,55},{20,52}}, D.RED, 3.5)
D.lit(c:poly{{8,14},{20,10},{20,52},{8,55}}, D.RED, 2)
for _, y in ipairs{18,31,44} do D.fill(c:rect(8,y-(y>0 and 0 or 0),19,y+1), GO[4]) end
for _, y in ipairs{18,31,44} do c:px(8,y,GO[2]) end
local hr = c:poly{{29,27},{34,24},{39,27},{40,32},{34,40},{28,32}}
D.lit(hr, GO, 1.5)
D.lit(c:rect(46,30,51,38), GO, 1) D.fill(c:rect(48,32,49,35), D.INK)
D.fin()
