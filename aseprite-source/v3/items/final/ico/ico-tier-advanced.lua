local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-tier-advanced: orange hex badge with two stacked gold chevrons and rivets.
-- quirk: one rivet has popped out, leaving a dark hole.
local c = D.new("ico-tier-advanced")
local hex = c:poly{ {32, 6}, {55, 19}, {55, 45}, {32, 58}, {9, 45}, {9, 19} }
D.lit(c, hex, D.ORG, 6)
local inner = c:poly{ {32, 12}, {50, 22}, {50, 42}, {32, 52}, {14, 42}, {14, 22} }
c:fillMask(inner, D.ORG[2])
D.lit(c, inner:copy():shrink(1), D.ORG, 5, { amb = 0.2 })
D.lit(c, c:line({ {21, 33}, {32, 24}, {43, 33} }, 4), D.YEL, 2)
D.lit(c, c:line({ {21, 44}, {32, 35}, {43, 44} }, 4), D.YEL, 2)
for i, p in ipairs{ {32, 8}, {52, 20}, {52, 44}, {32, 55}, {12, 44}, {12, 20} } do
  if i == 5 then c:fillMask(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), D.ORG[1])
  else c:fillMask(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), D.YEL[5]) end
end
D.fin()
