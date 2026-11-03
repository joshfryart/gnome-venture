local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-lock: gold padlock with steel shackle and heart-shaped keyhole. quirk: a tiny cobweb corner and a hanging key tag.
local c = D.new("ico-lock")
local sh = D.sub(D.ell(32, 22, 12, 14), D.ell(32, 24, 7, 11)):cut(c:rect(0, 28, 63, 63))
sh:add(c:rect(20, 22, 25, 30)):add(c:rect(39, 22, 44, 30))
D.lit(sh, D.STEEL, 3)
D.lit(c:rrect(14, 28, 50, 56, 5), D.GOLD, 5)
D.fill(c:rect(15, 33, 49, 33), D.GOLD[5])
D.fill(D.heart(32, 41, 4), D.GOLD[1]) D.fill(c:rect(31, 44, 33, 50), D.GOLD[1])
D.px(18, 31, D.GOLD[6]) D.px(19, 31, D.GOLD[6])
D.lit(c:rect(53, 38, 59, 47), D.CREAM, 1)
D.ln(50, 42, 53, 42, D.RED[4])
D.fin()
