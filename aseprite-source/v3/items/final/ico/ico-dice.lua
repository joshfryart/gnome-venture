local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-dice: cream six-sided die tipped in three-quarter view, bold pips on each face.
-- quirk: the top face shows a single big red pip and one corner is chipped.
local c = D.new("ico-dice")
c:groundShadow(32, 58, 22, 3)
local top = c:poly{ { 32, 8 }, { 55, 21 }, { 32, 34 }, { 9, 21 } }
local left = c:poly{ { 9, 22 }, { 32, 35 }, { 32, 58 }, { 9, 45 } }
local right = c:poly{ { 33, 35 }, { 55, 22 }, { 55, 45 }, { 33, 58 } }
top:cut(c:poly{ { 55, 21 }, { 60, 21 }, { 55, 28 } })
D.fill(left, D.CREAM[3]) D.fill(right, D.CREAM[2]) D.fill(top, D.CREAM[6])
D.fill(D.isect(left, c:rect(0, 0, 63, 40)):shrink(0), D.CREAM[3])
-- edges
D.ln(c, 9, 22, 32, 35, D.CREAM[1]) D.ln(c, 55, 22, 33, 35, D.CREAM[2]) D.ln(c, 32, 35, 32, 58, D.CREAM[1])
-- right face shade deeper at bottom
D.fill(D.isect(right, c:rect(33, 52, 55, 58)), D.CREAM[1]) D.fill(D.isect(left, c:rect(9, 52, 31, 58)), D.CREAM[2])
-- top pip
D.lit(D.ell(32, 21, 4, 2.4), D.RED, 2)
-- left face: 3 pips diagonal
for _, p in ipairs{ { 15, 30 }, { 20, 38 }, { 26, 44 } } do D.lit(D.ell(p[1], p[2], 2.4, 2.8), { D.INK, D.INK, "#3a2030", "#51302b", "#51302b", "#6f4033" }, 1.5) end
-- right face: 2 pips
for _, p in ipairs{ { 40, 38 }, { 49, 46 } } do D.lit(D.ell(p[1], p[2], 2.4, 2.8), { D.INK, D.INK, "#3a2030", "#51302b", "#51302b", "#6f4033" }, 1.5) end
D.fin()
