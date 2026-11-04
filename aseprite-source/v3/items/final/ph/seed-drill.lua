local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- seed-drill (D15 first draft). A little push seed drill: wooden spoked wheel, seed hopper box on a beam, a thin tube dropping seeds into a furrow, two handles.
-- quirk: a tiny sprout already peeks up in the row behind the drill.
local c = D.new("seed-drill")
-- handles
D.H.cyl(c, 44, 20, 58, 7, function(t) return 1.3 end, R.tan)
D.H.cyl(c, 46, 25, 59, 14, function(t) return 1.2 end, R.tan)
-- beam from hub to hopper
D.H.cyl(c, 20, 42, 36, 30, function(t) return 1.5 end, R.brown)
-- hopper
local hop = c:poly{ { 26, 12 }, { 50, 12 }, { 46, 30 }, { 30, 30 } }
D.lit(c, hop, R.tan, 5)
D.lit(c, c:rect(27, 8, 49, 12), R.gold, 2)
for _, p in ipairs{ { 30, 9 }, { 35, 8 }, { 41, 9 }, { 46, 8 } } do c:px(p[1], p[2], R.gold[2]) end
c:fillMask(c:rect(28, 21, 48, 21), R.brown[2])
-- tube
D.H.cyl(c, 38, 30, 44, 48, function(t) return 1.1 end, R.stone)
c:fillMask(c:poly{ { 42, 48 }, { 47, 48 }, { 45, 55 } }, R.iron[3])
-- wheel
local wheel = D.ell(21, 43, 11, 11, 0)
wheel:cut(D.ell(21, 43, 7, 7, 0))
D.lit(c, wheel, R.wood or R.brown, 3)
D.ln(c, 21, 33, 21, 53, R.brown[3]) D.ln(c, 11, 43, 31, 43, R.brown[3]) D.ln(c, 14, 36, 28, 50, R.brown[3]) D.ln(c, 28, 36, 14, 50, R.brown[3])
D.lit(c, D.ell(21, 43, 2.4, 2.4, 0), R.stone, 1.5)
-- seeds falling and furrow
for _, p in ipairs{ { 45, 56 }, { 50, 57 } } do D.lit(c, D.ell(p[1], p[2], 1.4, 1, 0), R.gold, 1) end
c:fillMask(c:rect(8, 59, 56, 59), R.brown[2])
c:fillMask(c:rect(55, 54, 55, 58), R.fresh[4]) c:px(54, 54, R.fresh[5]) c:px(56, 53, R.fresh[5])
D.fin()
