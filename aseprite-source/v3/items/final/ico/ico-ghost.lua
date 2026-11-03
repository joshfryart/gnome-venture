local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-ghost: friendly pale ghost with a wavy hem, round mouth and stubby arms.
-- quirk: a little red gnome hat sits tilted on its head.
local c = D.new("ico-ghost")
local m = c:ellipse(31, 32, 17, 16):add(c:poly{ {14,32},{48,32},{48,52},{43,57},{39,52},{31,57},{25,52},{19,57},{14,52} })
m:add(c:ellipse(11, 40, 4, 3)):add(c:ellipse(52, 40, 4, 3))
D.lit(m, D.GHOST, 14, { amb = 0.08 })
c:fillMask(c:rect(22, 28, 24, 33), INK) c:px(22, 28, CR)
c:fillMask(c:rect(37, 28, 39, 33), INK) c:px(37, 28, CR)
D.fill(c:ellipse(31, 40, 2, 3), "#4a2463")
c:cheek(17, 38) c:cheek(40, 38)
local hat = c:poly{ {19,19},{44,19},{42,14},{38,7},{33,5},{29,10} }
D.lit(hat, D.RED, 6, { amb = 0.05 })
D.fill(c:rect(17, 17, 46, 19), "#fff4d6") D.fill(c:rect(17, 19, 46, 19), "#c9a98a")
D.lit(D.disc(34, 5, 2), D.YEL, 2)
D.fin()
