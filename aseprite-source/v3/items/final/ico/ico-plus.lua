local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-plus: chunky rounded plus sign in gold with a bevelled face.
-- quirk: a curling green vine winds around the lower arm, ending in one leaf.
local c = D.new("ico-plus")
local m = c:rrect(22, 6, 41, 57, 5):add(c:rrect(6, 22, 57, 41, 5))
D.lit(c, m, D.YEL, 8, { amb = 0.08 })
local f = c:rrect(26, 10, 37, 53, 3):add(c:rrect(10, 26, 53, 37, 3))
f:edge():each(function(x, y) if m:has(x, y) then c:px(x, y, D.YEL[2]) end end)
D.pts(c, { {27, 12}, {28, 12}, {27, 13}, {12, 27}, {12, 28}, {13, 27} }, D.YEL[6])
-- vine
local vine = { {24, 55}, {30, 51}, {36, 49}, {42, 52}, {44, 57}, {40, 59}, {38, 56} }
for i = 1, #vine - 1 do D.ln(c, vine[i][1], vine[i][2], vine[i+1][1], vine[i+1][2], D.GRN[3]) D.ln(c, vine[i][1], vine[i][2] + 1, vine[i+1][1], vine[i+1][2] + 1, D.GRN[2]) end
D.leaf(c, 30, 51, 22, 42, 3, D.GRN, {})
D.fin()
