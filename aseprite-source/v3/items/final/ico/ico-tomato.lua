local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-tomato: plump glossy red tomato, star calyx, curly vine.
-- quirk: a dewdrop of water on the shoulder and a corkscrew tendril.
local c = D.new("ico-tomato")
c:groundShadow(32, 57, 17, 2)
local m = c:ellipse(23, 37, 12, 15):add(c:ellipse(41, 37, 12, 15)):add(c:ellipse(32, 40, 17, 15))
m:cut(c:ellipse(32, 24, 3, 2))
D.lit(c, m, D.RED, 7, { amb = 0.05 })
c:fillMask(c:rect(16, 31, 19, 33), D.RED[6]) c:px(16, 31, CREAM)
local cal = D.star(c, 32, 25, 12, 4, 5)
D.lit(c, cal, D.GRN, 2)
D.lit(c, c:ellipse(32, 25, 3, 3), D.GRN, 2)
D.tube(c, { {32, 22}, {32, 14}, {37, 8} }, 3, D.GRN, 2)
local sp = D.arc(42, 11, 5, 180, -120, 14)
for _, q in ipairs(sp) do c:px(floor(q[1] + .5), floor(q[2] + .5), D.GRN[4]) end
local dr = c:ellipse(46, 28, 3, 3)
D.lit(c, dr, D.ICE, 2) c:px(45, 27, CREAM)
D.fin()
