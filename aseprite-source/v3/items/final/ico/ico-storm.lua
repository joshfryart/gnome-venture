local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-storm: heavy grey thundercloud, a jagged yellow lightning bolt and falling rain.
-- quirk: a small separate puff has broken off the cloud and drifts at its side.
local c = D.new("ico-storm")
local cl = D.ell(24, 24, 11, 9):add(D.ell(38, 20, 12, 11)):add(D.ell(46, 28, 9, 7)):add(c:rect(14, 26, 52, 33)):add(D.ell(15, 30, 7, 4))
D.lit(c, cl, D.GRY, 10, { amb = 0.12 })
D.rect(c, 13, 32, 54, 33, D.GRY[2]) D.ln(c, 28, 12, 36, 10, D.GRY[6])
D.ln(c, 45, 27, 52, 30, D.GRY[2])
local bolt = c:poly{ {34,28},{24,42},{31,42},{25,58},{42,38},{34,38},{40,28} }
D.lit(c, bolt, D.YEL, 5, { amb = 0.2 })
D.ln(c, 33, 32, 28, 40, D.YEL[6])
for _, q in ipairs{ {14,40},{18,50},{48,42},{52,52} } do D.rect(c, q[1], q[2], q[1] + 1, q[2] + 3, D.BLU[4]) c:px(q[1], q[2], D.BLU[6]) end
D.lit(c, D.ell(56, 14, 4, 3), D.GRY, 3)
D.fin()
