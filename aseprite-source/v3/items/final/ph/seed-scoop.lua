local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- seed-scoop (D15 first draft). A steel scoop heaped with seeds, wooden handle with a ferrule angling up right, a few seeds spilled below.
-- quirk: one seed on top of the heap has already sprouted.
local c = D.new("seed-scoop")
D.H.cyl(c, 32, 38, 56, 12, function(t) return 1.8 end, R.tan)
D.lit(c, D.ell(34, 36, 2.6, 2.6, 0), R.gold, 2)
local body = D.ell(21, 43, 15, 10, -0.3)
D.lit(c, body, R.stone, 5)
D.lit(c, D.ell(21, 41, 12, 6.5, -0.3), R.iron, 3)
local heap = D.ell(21, 38, 11, 5.5, -0.3)
D.lit(c, heap, R.gold, 4)
for _, p in ipairs{ { 14, 38 }, { 18, 35 }, { 22, 38 }, { 26, 36 }, { 17, 40 }, { 24, 40 }, { 29, 38 } } do
  c:px(p[1], p[2], R.gold[1]) c:px(p[1] + 1, p[2], R.gold[1])
end
-- sprout
D.ln(c, 20, 33, 20, 25, "#78bd5c")
D.lit(c, D.ell(17, 25, 3, 1.8, -0.4), R.fresh, 1.5)
D.lit(c, D.ell(24, 24, 3, 1.8, 0.4), R.fresh, 1.5)
-- spilled
for _, p in ipairs{ { 38, 52 }, { 44, 55 }, { 33, 56 }, { 49, 51 } } do D.seed(c, p[1], p[2], 2, 1.4, 0.5, R.gold, "#74422f") end
c:px(10, 40, R.stone[6]) c:px(11, 39, R.stone[6])
D.fin()
