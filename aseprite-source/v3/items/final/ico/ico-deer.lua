local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-deer: slim brown deer standing in profile, branching antlers, cream spots and tail.
-- quirk: a small pink flower is caught in its antlers.
local c = D.new("ico-deer")
local R = D.BRN
-- far legs
D.lit(c:line({ { 21, 40 }, { 20, 56 } }, 3), { R[1], R[1], R[2], R[3], R[3], R[4] }, 1.5)
D.lit(c:line({ { 38, 40 }, { 39, 56 } }, 3), { R[1], R[1], R[2], R[3], R[3], R[4] }, 1.5)
-- antlers
for _, l in ipairs{ { { 44, 12 }, { 42, 5 }, { 38, 2 } }, { { 42, 8 }, { 44, 2 } }, { { 51, 12 }, { 54, 5 }, { 58, 3 } }, { { 53, 8 }, { 51, 2 } } } do
  D.fill(c:line(l, 2), D.CREAM[3])
end
-- ears
D.lit(D.ell(43, 13, 2, 3.5, -0.5), R, 1.5)
-- neck, body, head
D.lit(c:line({ { 38, 34 }, { 46, 20 } }, 7), R, 3)
D.lit(D.ell(28, 36, 14, 8, 0.05), R, 6)
D.lit(D.ell(50, 18, 6, 4.4, 0.45), R, 3.5)
D.lit(D.ell(55, 21, 3.5, 2.6, 0.45), D.CREAM, 1.5)
D.px(57, 22, D.INK) D.px(58, 22, D.INK) D.px(50, 16, D.INK) D.px(49, 15, D.CR)
-- belly
D.fill(D.isect(D.ell(28, 40, 12, 3), c:rect(0, 41, 63, 63)), D.CREAM[3])
-- spots
for _, p in ipairs{ { 20, 32 }, { 26, 31 }, { 32, 32 }, { 23, 36 }, { 30, 36 } } do D.fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), D.CREAM[4]) end
-- near legs
D.lit(c:line({ { 17, 40 }, { 16, 57 } }, 3), R, 1.5)
D.lit(c:line({ { 34, 41 }, { 35, 57 } }, 3), R, 1.5)
D.fill(c:rect(15, 56, 18, 58), D.INK) D.fill(c:rect(34, 56, 37, 58), D.INK)
-- tail
D.lit(D.ell(13, 33, 2.4, 3.4, 0.5), D.CREAM, 1.5)
-- flower
D.fill(c:rect(45, 4, 47, 6), "#f5809f") D.px(46, 3, "#f5809f") D.px(46, 7, "#f5809f") D.px(44, 5, "#f5809f") D.px(48, 5, "#f5809f") D.px(46, 5, D.GOLD[4])
D.fin()
