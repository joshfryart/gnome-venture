-- ico-owl first draft (Sonnet). quirk: a loose feather drifts down from its wing
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-owl")
local FE = { "#3a2030", "#51302b", "#6f4033", "#864c33", "#a35f3c", "#c98a54" }
-- branch
D.lit(c:rect(4, 54, 60, 58), "wood", 2)
D.fill(c:rect(4, 54, 60, 54), "#e8b982")
-- feet
for _, x in ipairs{ 25, 28, 31, 35, 38, 41 } do D.fill(c:rect(x, 51, x, 54), "#f5b82e") end
-- body
local body = D.ell(32, 36, 17, 18)
D.lit(body, FE, 9, { amb = .1 })
-- ear tufts
D.lit(c:poly{ {17, 22}, {19, 11}, {26, 20} }, FE, 2) D.lit(c:poly{ {47, 22}, {45, 11}, {38, 20} }, FE, 2)
-- belly feathers
local belly = D.ell(32, 43, 10, 10)
D.lit(belly, D.CREAM, 5, { amb = .12 })
for _, p in ipairs{ {28,38},{36,38},{32,42},{26,44},{38,44},{32,48},{28,50},{36,50} } do
  D.fill(c:rect(p[1] - 1, p[2], p[1] + 1, p[2]), "#a35f3c") c:px(p[1], p[2] + 1, "#a35f3c")
end
-- facial discs + eyes
D.fill(D.ell(24, 26, 7, 7), "#f6e6bf") D.fill(D.ell(40, 26, 7, 7), "#f6e6bf")
for _, e in ipairs{ {24, 26}, {40, 26} } do
  D.fill(D.ell(e[1], e[2], 5, 5), "#ffe38a") D.fill(D.ell(e[1], e[2], 3, 3), INK) D.fill(c:rect(e[1] - 2, e[2] - 2, e[1] - 1, e[2] - 2), CR)
end
-- beak
D.fill(c:poly{ {30, 28}, {34, 28}, {32, 34} }, "#f5b82e") D.fill(c:rect(31, 29, 31, 30), "#ffe38a")
-- wing marks
D.ln(15, 32, 15, 44, FE[1]) D.ln(49, 32, 49, 44, FE[1])
-- loose feather
D.fill(c:poly{ {54, 36}, {58, 40}, {55, 47}, {52, 42} }, "#c98a54")
D.ln(54, 37, 55, 47, FE[2])
D.fin()
