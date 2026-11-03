-- ico-mushroom first draft (Sonnet). quirk: a baby mushroom wearing an acorn cap grows beside it
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-mushroom")
c:groundShadow(30, 57, 22, 2)
-- stem
local stem = c:poly{ {22, 56}, {24, 36}, {40, 36}, {42, 56} }
stem:add(D.ell(32, 55, 10, 2))
D.H.vcyl(c, stem, D.CREAM, 22, 42)
D.fill(c:rect(24, 37, 40, 39), D.CREAM[2])
-- ring skirt
D.lit(c:poly{ {22, 42}, {42, 42}, {45, 47}, {19, 47} }, D.CREAM, 2)
D.fill(c:rect(20, 47, 44, 47), D.CREAM[2])
-- cap
local cap = D.ell(32, 30, 23, 17):cut(c:rect(0, 34, 63, 63))
cap:add(c:rect(9, 30, 55, 36))
cap:cut(c:rect(0, 37, 63, 63))
D.lit(cap, "ember", 10, { amb = .1 })
D.fill(c:rect(9, 35, 55, 36), "#6e2038")
-- spots
for _, s in ipairs{ {20, 24, 4, 3}, {34, 18, 4, 3}, {44, 28, 3, 2}, {28, 30, 3, 2}, {50, 33, 2, 1} } do
  D.fill(D.ell(s[1], s[2], s[3], s[4]), CR) D.fill(c:rect(s[1] + 1, s[2] + s[4] - 1, s[1] + s[3] - 1, s[2] + s[4]), "#f6e6bf")
end
-- baby with acorn cap
D.lit(c:rrect(51, 48, 57, 56, 2), D.CREAM, 2)
D.lit(D.ell(54, 48, 5, 3), "wood", 2)
D.fill(c:rect(53, 44, 54, 46), "#51302b")
for x = 50, 58, 2 do c:px(x, 48, "#51302b") end
D.fin()
