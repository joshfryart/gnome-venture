-- ico-bell first draft (Sonnet). quirk: a red bow tied on its neck
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA1.lua")
local floor = math.floor
local c, P, HP, B = D.new("ico-bell"), D.P, D.HP, D.B
local W, GO, MO, SE, DU, PE, ST, EM = D.rp("wood"), D.rp("gold"), D.rp("moss"), D.rp("sea"), D.rp("dusk"), D.rp("petal"), D.rp("stone"), D.rp("ember")

local body = c:poly{{26,22},{38,22},{41,28},{42,38},{46,47},{50,51},{14,51},{18,47},{22,38},{23,28}}
body:add(c:ellipse(32,25,8,5))
D.cyl(body, GO, 14, 50)
for x = 21, 43 do if body:has(x,41) then c:px(x,41,GO[2]) end end
local lip = D.isect(body, c:rect(0,47,63,51)) D.lit(lip, GO, 1.5)
for y = 28, 40 do c:px(25,y,GO[6]) end c:px(25,41,GO[6])
local ring = B.ell(32,15,5,4.5) ring:cut(B.ell(32,15,2,1.8)) D.lit(ring, GO, 1.5)
D.lit(c:rect(30,18,34,22), GO, 1)
D.lit(B.ell(32,54,3.5,3), GO, 1.5)
D.lit(c:poly{{27,20},{31,23},{27,26}}, D.RED, 1) D.lit(c:poly{{37,20},{33,23},{37,26}}, D.RED, 1)
D.fill(c:rect(30,21,34,24), D.RED[4]) c:px(31,21,D.RED[6])
D.fin()
