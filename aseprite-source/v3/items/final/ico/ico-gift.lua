local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-gift: purple gift box with golden ribbon and a big bow.
-- quirk: a little cream tag with a heart dangles from a string.
local c = D.new("ico-gift")
c:groundShadow(32, 58, 22, 2)
local box = c:rect(12, 30, 51, 56)
D.lit(box, D.PURP, 14, { amb = 0.1 })
local lid = c:rect(9, 22, 54, 33)
D.lit(lid, D.PURP, 10, { amb = 0.05 })
D.fill(c:rect(10, 33, 53, 33), D.PURP[1])
local rb = c:rect(28, 22, 36, 56)
D.lit(rb, D.GOLD, 5, { amb = 0.08 })
local l1 = D.ell(24, 14, 8, 5, -0.5) local l2 = D.ell(40, 14, 8, 5, 0.5)
D.lit(l1, D.GOLD, 5) D.lit(l2, D.GOLD, 5)
D.lit(D.disc(32, 20, 4), D.GOLD, 3)
D.fill(D.ring(24, 14, 3, 1):shift(0, 0):clip(l1), D.GOLD[2])
-- tag
D.ln(c, 44, 34, 49, 44, "#c9a98a")
D.fill(c:poly{ {44,44},{54,44},{54,54},{44,54} }, CR)
D.fill(c:rect(45, 45, 53, 45), "#c9a98a")
D.fill(c:ellipse(47, 49, 1, 1):add(c:ellipse(51, 49, 1, 1)):add(c:poly{ {46,50},{52,50},{49,53} }), "#d4403a")
D.fin()
