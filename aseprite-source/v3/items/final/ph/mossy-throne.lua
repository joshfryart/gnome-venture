-- mossy-throne: slim carved stone chair with an arched back, moss on the crown and dripping off the seat. quirk: one yellow flower pushes out of a crack in the armrest.
local D = dofile(debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC24.lua")
local H, HP, B, X = D.H, D.HP, D.B, D.X
local floor, sin, cos, pi, max, min, abs = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs
local c = D.new("mossy-throne")
local ST = D.R("#e2e0e6", "#aaa9b8", "#74758c", "#444663")
local MS = D.R("#d4f08a", "#7cc35a", "#3f9150", "#24544a")
c:groundShadow(32, 57, 22, 2)
local back = c:rrect(20, 8, 43, 36, 7):add(c:rect(20, 20, 43, 36))
B.lit(c, back, ST, 6)
c:fillMask(c:rrect(24, 13, 39, 30, 4), ST.shade) c:fillMask(c:rrect(25, 14, 38, 28, 3), "#8e90a8")
local dm = c:poly{ {32,17}, {36,22}, {32,27}, {28,22} }
B.lit(c, dm, "gold", 1.8)
for _, l in ipairs{ {{21,22},{21,35}}, {{42,16},{42,35}} } do B.ln(c, l[1][1], l[1][2], l[2][1], l[2][2], ST.hi, back) end
for _, l in ipairs{ {14,26,21,44}, {42,26,49,44} } do
  local arm = c:rrect(l[1], l[2], l[3], l[4], 3)
  B.lit(c, arm, ST, 3)
end
local seat = c:rrect(14, 38, 49, 47, 3)
B.lit(c, seat, ST, 3)
B.ln(c, 16, 39, 46, 39, ST.hi, seat)
for _, x in ipairs{ 16, 41 } do
  local leg = c:rrect(x, 47, x + 6, 56, 2)
  B.lit(c, leg, ST, 2)
end
-- cracks
B.polyline(c, { {30,30}, {31,34}, {29,37} }, ST.deep) 
B.polyline(c, { {16,30}, {17,33}, {16,36} }, ST.deep)
-- moss
for _, p in ipairs{ {26,9,5}, {33,7,5}, {39,10,4}, {20,40,4}, {30,43,5}, {41,44,4} } do
  local m = c:ellipse(p[1], p[2], p[3], p[3] * .7)
  B.lit(c, m, MS, 2.4) D.speck(c, m, MS.hi, p[1], .85)
end
for _, p in ipairs{ {20,45}, {30,47}, {41,48} } do c:fillMask(c:rect(p[1], p[2], p[1] + 1, p[2] + 2), MS.shade) c:px(p[1], p[2], MS.base) end
-- flower
c:px(16, 26, "#3f9150") c:px(16, 25, "#3f9150")
for _, p in ipairs{ {16,23}, {14,24}, {18,24}, {16,25} } do c:px(p[1], p[2], "#f5b82e") end
c:px(16, 24, "#fff4d6")
D.fin()
