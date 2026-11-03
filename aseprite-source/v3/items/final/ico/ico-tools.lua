local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-tools: crossed wrench and hammer, bold steel and wood.
-- quirk: a runaway hex nut is caught in the wrench jaw.
local c = D.new("ico-tools")
-- hammer: wood handle bottom-right to top-left
D.lit(c, c:line({ {50, 54}, {21, 18} }, 5), D.WOOD, 2)
local ux, uy = -0.63, -0.78
local px, py = 0.78, -0.63
local function pt(a, b) return { floor(20 + px * a + ux * b + .5), floor(15 + py * a + uy * b + .5) } end
D.lit(c, c:poly{ pt(-11, -4), pt(11, -4), pt(11, 5), pt(-11, 5) }, D.GRY, 3)
-- wrench: steel from bottom-left to top-right
D.lit(c, c:line({ {13, 53}, {44, 20} }, 5), D.GRY, 2)
local head = c:ellipse(47, 16, 8, 8)
head:cut(c:poly{ {47, 16}, {52, 5}, {58, 11} }:add(c:ellipse(52, 11, 2, 2)))
D.lit(c, head, D.GRY, 3)
D.lit(c, c:ellipse(12, 55, 4, 4), D.GRY, 2)
c:fillMask(c:ellipse(12, 55, 1, 1), D.GRY[1])
-- nut
local nut = c:poly{ {51, 8}, {55, 8}, {57, 11}, {55, 14}, {51, 14}, {49, 11} }
D.lit(c, nut, D.GOLD, 2) c:fillMask(c:rect(52, 10, 54, 12), D.GOLD[1])
D.fin()
