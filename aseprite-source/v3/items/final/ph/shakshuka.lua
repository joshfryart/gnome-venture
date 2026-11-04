local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- shakshuka (D15 first draft). A cast-iron pan of bubbling tomato sauce with two eggs, green parsley and a pepper ring; short handle to the right and a steam curl.
-- quirk: the steam curl above the pan curls into a little question mark.
local c = D.new("shakshuka")
c:groundShadow(28, 54, 24, 3)
D.H.cyl(c, 44, 40, 59, 35, function(t) return 2.2 - 0.4 * t end, R.iron)
c:px(57, 36, R.iron[5])
D.lit(c, D.ell(27, 42, 23, 13, 0), R.iron, 5)
D.lit(c, D.ell(27, 38, 23, 13, 0), R.iron, 6)
D.lit(c, D.ell(27, 38, 19, 10, 0), R.red, 5)
-- eggs
D.lit(c, D.ell(21, 37, 8, 5, 0.1), R.cream, 3)
D.lit(c, D.ell(34, 39, 7, 4.5, -0.1), R.cream, 3)
D.lit(c, D.ell(21, 36, 3, 2.6, 0), R.gold, 2)
D.lit(c, D.ell(34, 38, 2.8, 2.4, 0), R.gold, 2)
c:px(20, 35, D.CREAM) c:px(33, 37, D.CREAM)
for _, p in ipairs{ { 14, 36 }, { 28, 33 }, { 39, 36 }, { 26, 43 }, { 18, 42 }, { 40, 41 } } do c:px(p[1], p[2], R.fresh[5]) c:px(p[1] + 1, p[2], R.leaf[4]) end
for _, p in ipairs{ { 30, 31 }, { 12, 38 }, { 38, 43 } } do c:px(p[1], p[2], R.red[6]) end
-- steam
D.polyline(c, { { 22, 24 }, { 23, 21 }, { 21, 18 }, { 23, 15 }, { 25, 14 }, { 27, 15 }, { 27, 17 }, { 25, 19 }, { 25, 21 } }, "#e4f6ff")
D.fin()
