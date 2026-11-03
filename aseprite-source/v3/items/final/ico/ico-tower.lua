local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-tower: round stone tower with a pointy red roof, arched door and window.
-- quirk: ivy climbs up the left side and a small flag flutters from the spire.
local c = D.new("ico-tower")
c:groundShadow(32, 57, 18, 2)
local body = c:rect(18, 24, 46, 56)
D.lit(c, body, D.GRY, 8, { amb = 0.1 })
for y = 28, 54, 6 do c:fillMask(c:rect(19, y, 45, y), D.GRY[2]) end
for r = 0, 4 do for x = 22 + (r % 2) * 6, 44, 12 do c:fillMask(c:rect(x, 28 + r * 6 - 5, x, 28 + r * 6 - 1), D.GRY[2]) end end
D.lit(c, c:poly{ {13, 27}, {51, 27}, {32, 5} }, D.RED, 5)
D.lit(c, c:rrect(14, 24, 50, 29, 2), D.RED, 2)
D.lit(c, c:rrect(28, 41, 36, 56, 4), D.WOOD, 3)
c:fillMask(c:rrect(29, 31, 35, 38, 2), D.GRY[1])
c:fillMask(c:rect(30, 32, 31, 34), D.ICE[3])
c:line({ {32, 5}, {32, 1} }, 1)
c:fillMask(c:poly{ {32, 1}, {40, 3}, {32, 6} }, D.GOLD[4])
for _, p in ipairs{ {18, 52}, {19, 47}, {18, 42}, {20, 37}, {19, 32} } do D.lit(c, c:ellipse(p[1], p[2], 2, 2), D.GRN, 2) end
D.fin()
