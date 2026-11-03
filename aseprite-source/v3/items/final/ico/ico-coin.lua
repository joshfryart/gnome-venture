local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-coin: fat gold coin seen face on with a thick edge, raised rim ring and an embossed star.
-- quirk: someone has taken a bite out of the upper-right edge.
local c = D.new("ico-coin")
local edge = D.disc(33, 34, 20)
local face = D.disc(32, 32, 20)
local bite = D.ell(51, 15, 4.5, 4.5)
edge:cut(D.ell(52, 16, 4.5, 4.5)) face:cut(bite)
D.fill(edge, D.GOLD[2])
D.radial(edge, 33, 34, 18, 22, D.GOLD[1])
D.lit(face, D.GOLD, 9)
D.radial(face, 32, 32, 15, 16, D.GOLD[2])
D.radial(face, 32, 32, 16, 17, D.GOLD[5])
local pts = {}
for i = 0, 9 do local r = (i % 2 == 0) and 11 or 5 local a = -pi / 2 + i * pi / 5 pts[#pts + 1] = { 32 + cos(a) * r, 32 + sin(a) * r } end
local star = c:poly(pts)
D.fill(star:shift(1, 1), D.GOLD[1])
D.fill(star, D.GOLD[5])
D.fill(star:copy():shrink(1), D.GOLD[4])
c:px(30, 25, D.GOLD[6]) c:px(31, 25, D.GOLD[6])
D.fin()
