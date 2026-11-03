local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-sun-rain: golden sun peeking over a blue-grey rain cloud, three raindrops falling.
-- quirk: a tiny three-band rainbow arcs between the sun and the cloud.
local c = D.new("ico-sun-rain")
for i = 0, 7 do
  local a = i * pi / 4 + pi / 8 local ux, uy = cos(a), sin(a) local px, py = -uy, ux
  local pts = { { 22 + ux * 12 + px * 3, 20 + uy * 12 + py * 3 }, { 22 + ux * 19, 20 + uy * 19 }, { 22 + ux * 12 - px * 3, 20 + uy * 12 - py * 3 } }
  for _, p in ipairs(pts) do p[1] = floor(p[1] + .5) p[2] = floor(p[2] + .5) end
  D.poly(c, pts, D.ORG, 3, { amb = 0.2 })
end
D.disc(c, 22, 20, 11, D.YEL)
local cl = D.ell(32, 36, 10, 8):add(D.ell(45, 34, 10, 9)):add(c:rect(20, 38, 55, 42)):add(D.ell(20, 41, 5, 3)):add(D.ell(54, 41, 4, 3))
D.lit(c, cl, D.BLU, 10, { amb = 0.15 })
D.rect(c, 19, 42, 55, 43, D.BLU[2]) D.ln(c, 28, 30, 36, 28, D.BLU[6])
for _, x in ipairs{ 26, 38, 49 } do D.rect(c, x, 47, x + 1, 53, D.BLU[4]) c:px(x, 47, D.BLU[6]) D.rect(c, x, 55, x + 1, 56, D.BLU[3]) end
-- rainbow
for r = 0, 2 do local col = ({ D.RED[4], D.YEL[4], D.GRN[4] })[r + 1]
  for a = 180, 360, 6 do local t = a * pi / 180 c:px(floor(50 + cos(t) * (10 - r) + .5), floor(24 + sin(t) * (10 - r) + .5), col) end end
D.fin()
