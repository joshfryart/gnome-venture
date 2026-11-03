local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA6.lua")
local HP, INK, CR, floor = D.HP, D.INK, D.CR, math.floor
-- ico-leaf: one big moss leaf on a curved stalk, veined. quirk: a dewdrop on it holds a sparkle.
local c = D.new("ico-leaf")
D.lit(D.seg({{18,56},{22,48},{26,42}}, 3), D.GREEN, 1)
D.leaf(24, 44, 50, 8, 15, "moss", {6, 12, 18, 24})
D.leaf(24, 44, 8, 20, 7, "moss", {5, 10, 15})
local dr = D.ell(40, 28, 2.6, 3) D.lit(dr, "sea", 2)
D.px(39, 26, D.CR)
c:sparkle(52, 24)
D.fin()
