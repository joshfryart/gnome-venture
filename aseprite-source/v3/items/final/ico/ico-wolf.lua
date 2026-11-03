local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA11.lua")
local HP, INK, CREAM = D.HP, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-wolf: grey wolf head in profile facing right, tall ears, long snout, pink tongue.
-- quirk: the near ear has a torn notch from an old scrap.
local c = D.new("ico-wolf")
local ear2 = c:poly{ {28, 24}, {36, 6}, {42, 26} }
D.lit(c, ear2, D.FUR, 2)
local ear = c:poly{ {13, 28}, {16, 5}, {30, 24} }
ear:cut(c:poly{ {16, 5}, {20, 11}, {17, 12} })
D.lit(c, ear, D.FUR, 3)
D.lit(c, c:poly{ {17, 12}, {18, 24}, {24, 22} }, D.PINK, 1)
local head = c:ellipse(28, 38, 17, 15):add(c:ellipse(46, 43, 12, 7)):add(c:poly{ {14, 40}, {26, 54}, {42, 50}, {44, 36} })
D.lit(c, head, D.FUR, 8, { amb = 0.05 })
D.lit(c, c:ellipse(38, 51, 12, 5), D.FUR, 2)
c:fillMask(c:rect(46, 49, 56, 49), D.FUR[1])
D.lit(c, c:ellipse(56, 41, 3, 3), D.FUR, 1)
c:fillMask(c:ellipse(57, 40, 2.5, 2.5), INK) c:px(56, 39, CREAM)
D.lit(c, c:rrect(46, 51, 51, 57, 2), D.PINK, 2)
c:eyeSmall(37, 31)
c:fillMask(c:rect(33, 28, 41, 28), D.FUR[1])
c:fillMask(c:poly{ {14, 40}, {20, 46}, {14, 48} }, D.FUR[5])
c:sparkle(10, 16)
D.fin()
