local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-target: archery target, red and cream rings with a gold bullseye, an arrow stuck in the red ring.
-- quirk: a ladybug is sunning itself on the target's top rim.
local c = D.new("ico-target")
c:groundShadow(32, 58, 18, 2)
D.disc(c, 30, 34, 23, D.BRN)
D.disc(c, 30, 34, 20, D.CRM)
D.disc(c, 30, 34, 15, D.RED)
D.disc(c, 30, 34, 10, D.CRM)
D.disc(c, 30, 34, 5, D.YEL)
c:px(27, 31, D.YEL[6])
D.cyl(c, 38, 26, 55, 9, function() return 1.3 end, D.BRN, { amb = 0.1 })
D.leaf(c, 52, 12, 59, 5, 2.5, D.RED) D.leaf(c, 54, 14, 61, 11, 2.5, D.RED)
D.rect(c, 36, 28, 38, 30, D.BRN[1])
D.ladybug(c, 28, 7)
D.fin()
