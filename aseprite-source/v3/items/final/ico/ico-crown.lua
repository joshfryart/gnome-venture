local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-crown: chunky gold crown, three tall points with ball tips, band set with three gems.
-- quirk: a small green leaf sprouts from the band at the right (a crown for a garden king).
local c = D.new("ico-crown")
local body = c:poly{ { 10, 42 }, { 8, 16 }, { 21, 29 }, { 32, 10 }, { 43, 29 }, { 56, 16 }, { 54, 42 } }
D.lit(body, D.GOLD, 7)
for _, p in ipairs{ { 8, 15 }, { 32, 9 }, { 56, 15 } } do D.lit(D.disc(p[1], p[2], 3.4), D.GOLD, 2.5) D.px(p[1] - 1, p[2] - 1, D.GOLD[6]) end
local band = c:rrect(9, 40, 55, 53, 2)
D.lit(band, D.GOLD, 5)
D.fill(c:rect(9, 40, 55, 40), D.GOLD[2])
D.fill(c:rect(11, 51, 53, 51), D.GOLD[1])
local gems = { { 18, 47, D.RED }, { 32, 47, D.BLUE }, { 46, 47, D.GREEN } }
for _, g in ipairs(gems) do
  D.lit(D.disc(g[1], g[2], 3.4), g[3], 2.5, {})
  D.px(g[1] - 1, g[2] - 1, D.CR)
end
D.lit(D.ell(57, 37, 4.5, 2.2, -0.6), "moss", 1.6)
D.fin()
