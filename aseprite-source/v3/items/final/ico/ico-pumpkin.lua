local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-pumpkin: plump orange pumpkin of three fat ribs with dark grooves, a stubby stem and a curly tendril.
-- quirk: a tiny crooked grin is carved into the middle rib.
local c = D.new("ico-pumpkin")
c:groundShadow(32, 56, 22, 2)
local L, R, M = D.ell(20, 38, 10, 14), D.ell(44, 38, 10, 14), D.ell(32, 38, 12, 16)
D.lit(c, L, D.ORG, 7, { amb = 0.1 }) D.lit(c, R, D.ORG, 7, { amb = 0.1 })
D.lit(c, M, D.ORG, 8, { amb = 0.08 })
M:edge():each(function(x, y) if L:has(x, y) or R:has(x, y) or M:has(x, y) then end end)
for y = 24, 54 do
  local w = floor(sqrt(max(0, 1 - ((y - 38) / 16) ^ 2)) * 12 + .5)
  if w > 0 then c:px(32 - w, y, D.ORG[1]) c:px(32 + w, y, D.ORG[1]) end
end
D.rect(c, 28, 22, 36, 24, D.GRN[1])
D.cyl(c, 31, 24, 34, 12, function(t) return 3 - t end, D.GRN, { amb = 0.1 })
D.polyline(c, { {35, 15}, {41, 14}, {44, 18}, {41, 21}, {38, 19} }, D.GRN[3])
D.polyline(c, { {35, 16}, {41, 15}, {43, 18}, {41, 20} }, D.GRN[2])
-- carved grin
D.rect(c, 28, 38, 29, 39, D.ORG[1]) D.rect(c, 35, 38, 36, 39, D.ORG[1])
D.pts(c, { {28, 44}, {29, 45}, {30, 45}, {31, 45}, {32, 45}, {33, 45}, {34, 44}, {35, 44}, {36, 43} }, D.ORG[1])
D.pts(c, { {17, 30}, {17, 31}, {18, 29} }, D.ORG[6])
D.fin()
