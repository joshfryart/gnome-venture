local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- shea (D15 first draft). A short branch with two glossy veined leaves, one whole green shea fruit and one fruit cut open to show the pale flesh and brown nut.
-- quirk: a bite is gone from the whole fruit's shoulder.
local c = D.new("shea")
D.H.cyl(c, 7, 11, 40, 20, function(t) return 1.5 end, R.brown)
D.blade(c, 20, 15, 8, 30, 5, R.leaf, { veins = { 3, 6, 9, 12, 15 }, slant = 1.6 })
D.blade(c, 32, 18, 52, 10, 5, R.leaf, { veins = { 3, 6, 9, 12, 15, 18 }, slant = 1.6 })
D.ln(c, 40, 20, 41, 30, R.brown[3])
D.ln(c, 28, 17, 22, 38, R.brown[3])
-- whole fruit
local f = D.ell(42, 38, 9, 10, 0)
f:cut(D.ell(49, 31, 3.4, 3.4, 0))
D.lit(c, f, R.olive, 6)
c:px(37, 33, R.olive[6]) c:px(38, 33, R.olive[6]) c:px(36, 34, R.olive[6])
-- cut fruit
D.lit(c, D.ell(21, 47, 9, 9, 0), R.olive, 5)
D.lit(c, D.ell(21, 47, 6.6, 6.6, 0), R.cream, 4)
D.lit(c, D.ell(21, 47, 3.6, 4.4, 0), R.brown, 3)
c:px(20, 44, "#dcb07a") c:px(21, 44, "#dcb07a")
c:px(19, 49, R.cream[5]) c:px(23, 50, R.cream[5])
D.fin()
