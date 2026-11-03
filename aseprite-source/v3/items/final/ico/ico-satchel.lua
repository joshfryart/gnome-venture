-- ico-satchel first draft. leather satchel, flap, buckle, top handle. quirk: a stitched green patch mends a tear, a feather pokes out
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA9.lua")
local c = D.new("ico-satchel")
c:groundShadow(32, 55, 22, 3)
-- feather
D.lit(c, D.ell(44, 14, 3, 8, 0.5), D.RED, 1.5)
D.polyline(c, { {41, 20}, {46, 9} }, "#fff4d6")
-- handle
local h = D.ell(32, 25, 13, 12):cut(D.ell(32, 25, 8, 8)):clip(c:rect(0, 0, 63, 28))
D.lit(c, h, D.BRN, 2.2)
-- body
D.lit(c, c:rrect(9, 26, 55, 53, 4), D.TAN, 6, { amb = 0.1 })
D.lit(c, c:rrect(9, 26, 55, 53, 4), { "#4a2418", "#6f3a22", "#8a4a26", "#a8643a", "#c98a54", "#e8b078" }, 6)
-- flap
local flap = c:poly{ {9, 26}, {55, 26}, {55, 34}, {50, 40}, {32, 43}, {14, 40}, {9, 34} }
D.lit(c, flap, { "#3a2030", "#5a2e1e", "#7a4026", "#9a5832", "#b8743e", "#d89a5c" }, 4)
D.polyline(c, { {10, 35}, {14, 40}, {32, 43}, {50, 40}, {54, 35} }, "#3a2030")
-- buckle
D.lit(c, c:rect(28, 38, 36, 47), D.GOLD, 1.5) D.R(c, 30, 40, 34, 45, "#8f4a1f") D.R(c, 31, 41, 33, 44, "#ffd45a")
-- patch
D.lit(c, c:rect(40, 45, 51, 52), "moss", 1.2)
c:stitch({ {40, 45}, {51, 45}, {51, 52}, {40, 52}, {40, 45} })
D.fin()
