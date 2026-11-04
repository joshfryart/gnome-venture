local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- second-spoon (D15 first draft). A big silver spoon and a smaller gold second spoon lying side by side, diagonal.
-- quirk: the little second spoon has a kinked handle and carries one drop of soup.
local c = D.new("second-spoon")
-- small gold spoon behind
D.H.cyl(c, 34, 46, 55, 26, function(t) return 1.1 + 0.5 * t end, R.gold)
local b2 = D.ell(30, 50, 6, 4, -0.75)
D.lit(c, b2, R.gold, 3)
D.lit(c, D.ell(30, 50, 3.6, 2.2, -0.75), { R.gold[1], R.gold[1], R.gold[2], R.gold[2], R.gold[3], R.gold[3] }, 2)
c:px(28, 49, R.gold[6]) c:px(33, 52, "#e8493b") c:px(32, 52, "#e8493b")
-- big silver spoon
D.H.cyl(c, 23, 38, 47, 11, function(t) return 1.2 + 0.7 * t end, R.stone)
local b1 = D.ell(17, 44, 9, 6.5, -0.75)
D.lit(c, b1, R.stone, 4)
D.lit(c, D.ell(17, 44, 6.4, 4, -0.75), { R.stone[1], R.stone[2], R.stone[2], R.stone[3], R.stone[3], R.stone[4] }, 2)
c:px(13, 42, R.stone[6]) c:px(14, 41, R.stone[6])
c:sparkle(50, 40)
D.fin()
