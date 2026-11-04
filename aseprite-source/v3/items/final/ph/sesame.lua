local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- sesame (D15 first draft). A slim sesame stalk: opposite lance leaves, upright four-sided green pods hugging the stem, a pink bell flower on top.
-- quirk: one pod has split open and is dropping a few cream seeds.
local c = D.new("sesame")
D.blade(c, 31, 52, 8, 44, 4.5, R.leaf, { veins = { 5, 9, 13, 17 } })
D.blade(c, 32, 48, 54, 40, 4.5, R.leaf, { veins = { 5, 9, 13, 17 } })
D.blade(c, 32, 36, 16, 28, 3.6, R.fresh, { veins = { 4, 8, 12 } })
D.blade(c, 33, 33, 50, 25, 3.6, R.fresh, { veins = { 4, 8, 12 } })
D.H.cyl(c, 31, 58, 33, 8, function(t) return 1.5 - 0.4 * t end, R.olive)
-- pods
D.lit(c, D.ell(37, 29, 2.4, 7, 0.1), R.olive, 2)
D.lit(c, D.ell(28, 27, 2.4, 6.5, -0.1), R.olive, 2)
D.ln(c, 37, 23, 37, 34, R.olive[2]) D.ln(c, 28, 22, 28, 32, R.olive[2])
-- split pod
D.lit(c, D.ell(37, 43, 2.8, 7, 0), R.tan, 2.2)
D.ln(c, 37, 38, 37, 42, R.brown[1])
for _, p in ipairs{ { 39, 50 }, { 41, 54 }, { 38, 57 } } do D.seed(c, p[1], p[2], 1.8, 1.1, 0.4, R.cream, "#1f553f", false) end
-- flowers
D.lit(c, D.ell(33, 14, 4, 5, 0.2), R.pink, 3)
D.lit(c, D.ell(38, 20, 3.4, 4, -0.5), R.pink, 2.5)
c:fillMask(c:rect(32, 17, 34, 18), D.CREAM)
D.fin()
