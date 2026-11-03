local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-drum: red snare drum with cream skin, zigzag lacing and gold hoops, two sticks on top.
-- quirk: one drumstick is a carrot.
local c = D.new("ico-drum")
c:groundShadow(32, 56, 20, 3)
local body = c:rect(11, 32, 53, 50):add(D.ell(32, 50, 21, 6))
body:cut(c:rect(0, 0, 63, 31))
D.lit(body, D.RED, 8)
D.lit(D.isect(body, c:rect(0, 32, 63, 34)), D.GOLD, 1.5, {})
D.fill(D.isect(D.ell(32, 51, 21, 6), c:rect(0, 51, 63, 56)), D.GOLD[2])
-- lacing
for x = 14, 48, 6 do D.fill(c:line({ { x, 35 }, { x + 3, 49 } }, 1), D.CREAM[4]) D.fill(c:line({ { x + 6, 35 }, { x + 3, 49 } }, 1), D.CREAM[3]) end
-- top skin
D.lit(D.ell(32, 32, 21, 7), D.GOLD, 5, {})
D.lit(D.ell(32, 32, 18, 5), D.CREAM, 4, {})
-- sticks
D.fill(c:line({ { 16, 8 }, { 34, 30 } }, 3), D.BRN[5]) D.lit(D.disc(16, 8, 3), D.BRN, 2)
D.fill(c:line({ { 48, 6 }, { 30, 30 } }, 4), D.ORG[3]) D.fill(c:line({ { 47, 6 }, { 31, 28 } }, 1), D.ORG[5])
D.fill(c:line({ { 48, 6 }, { 50, 2 } }, 1), "#3fa862") D.fill(c:rect(47, 2, 49, 4), "#3fa862") D.fill(c:rect(51, 3, 53, 5), "#6cc880")
D.fin()
