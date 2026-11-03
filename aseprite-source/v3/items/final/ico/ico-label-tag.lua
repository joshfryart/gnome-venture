local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-label-tag: hanging cream tag with cut corners on a red string, scribbled price lines. quirk: a small heart is stamped on it.
local c = D.new("ico-label-tag")
local tag = D.rot(c:poly{{24,16},{40,16},{46,22},{46,54},{18,54},{18,22}}, 32, 36, 0.28)
D.lit(tag, D.CREAM, 3)
local hole = D.rot(D.ell(32, 22, 3, 3), 32, 36, 0.28)
D.fill(hole, D.BRN[2]) 
D.lit(D.seg({{32,22},{22,10},{12,10},{10,16}}, 2), D.RED, 1)
D.rot(c:rect(24, 32, 38, 33), 32, 36, 0.28):each(function(x, y) D.px(x, y, D.CREAM[1]) end)
D.rot(c:rect(24, 46, 34, 47), 32, 36, 0.28):each(function(x, y) D.px(x, y, D.CREAM[1]) end)
D.lit(D.rot(D.heart(32, 40, 4), 32, 36, 0.28), D.RED, 1.5)
D.fin()
