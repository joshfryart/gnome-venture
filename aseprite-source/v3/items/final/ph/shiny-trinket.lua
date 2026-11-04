local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD15.lua")
local HP, X, K, R = D.HP, D.X, D.K, D.R
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
-- shiny-trinket (D15 first draft). A gold star charm with a red gem at the heart, hanging from a bail ring and a short chain loop; two cream sparkles.
-- quirk: one point of the star is dented where it was once dropped.
local c = D.new("shiny-trinket")
local pts = {}
for i = 0, 9 do
  local r = (i % 2 == 0) and 22 or 10
  local a = -pi / 2 + i * pi / 5
  pts[#pts + 1] = { floor(32 + r * cos(a) + 0.5), floor(38 + r * sin(a) * 0.98 + 0.5) }
end
pts[1][2] = pts[1][2] + 1
local star = c:poly(pts)
star:cut(D.ell(51, 30, 2, 2, 0))
D.lit(c, star, R.gold, 5)
-- bail + chain
local bail = D.ell(32, 12, 4.5, 4, 0) bail:cut(D.ell(32, 12, 2, 1.6, 0))
D.lit(c, bail, R.gold, 1.8)
D.lit(c, D.ell(24, 8, 2.6, 2, 0.5), R.stone, 1.5)
D.lit(c, D.ell(18, 12, 2.6, 2, -0.5), R.stone, 1.5)
-- gem
D.lit(c, D.ell(32, 38, 6, 6, 0), R.red, 5)
D.lit(c, D.ell(32, 38, 7, 7, 0):cut(D.ell(32, 38, 6, 6, 0)), R.gold, 1)
c:px(29, 35, D.CREAM) c:px(30, 35, D.CREAM) c:px(29, 36, D.CREAM)
c:sparkle(10, 24) c:sparkle(56, 52)
D.fin()
