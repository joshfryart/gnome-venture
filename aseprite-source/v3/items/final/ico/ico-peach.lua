local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-peach: bold peach, two soft lobes with a deep crease, fuzzy bloom, short stem and one leaf.
-- quirk: a single dewdrop clings to the cheek of the fruit.
local c = D.new("ico-peach")
c:groundShadow(32, 56, 15, 2)
local body = D.ell(24, 37, 13, 15):add(D.ell(40, 37, 13, 15)):add(c:ellipse(32, 38, 12, 14))
D.lit(c, body, D.PEACH, 10, { amb = 0.06 })
for y = 23, 52 do local x = 31 + floor(sin((y - 23) / 29 * pi) * 2) c:px(x, y, D.PEACH[1]) c:px(x + 1, y, D.PEACH[2]) end
c:px(32, 22, D.PEACH[1]) c:px(33, 22, D.PEACH[2])
D.rect(c, 31, 14, 33, 22, "#6a4a30") c:px(31, 15, "#9a7048") c:px(31, 16, "#9a7048")
D.leaf(c, 34, 19, 52, 10, 5, "moss", { 4 })
c:fillMask(c:rect(17, 29, 20, 30), D.PEACH[6]) c:px(17, 31, D.PEACH[6])
-- dewdrop
local d = c:ellipse(43, 43, 2, 3)
c:fillMask(d, D.BLU[4]) c:px(42, 42, CREAM) c:px(43, 45, D.BLU[2]) c:px(44, 45, D.BLU[2])
D.fin()
