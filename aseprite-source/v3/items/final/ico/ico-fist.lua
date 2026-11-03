local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-fist: raised closed fist, four knuckles across the top, thumb over the fingers.
-- quirk: a cream plaster is stuck across one knuckle.
local c = D.new("ico-fist")
local cuff = c:rect(17, 48, 46, 58)
D.lit(cuff, D.RED, 6, { amb = 0.1 })
local hand = c:rrect(13, 12, 50, 52, 8)
D.lit(hand, D.SKIN, 14, { amb = 0.08 })
for _, x in ipairs{ 22, 31, 40 } do D.fill(c:rect(x, 14, x, 28), D.SKIN[2]) end
D.fill(c:rect(14, 30, 49, 30), D.SKIN[2])
local th = D.ell(30, 39, 14, 5.5, 0.1)
D.lit(th, D.SKIN, 5, { amb = 0.05 })
D.seam(c, th, c:rect(0,0,0,0), D.SKIN[1])
D.poly(c, { {17,38},{20,43} }, D.SKIN[2])
-- plaster
c:fillMask(c:poly{ {25,17},{31,15},{32,22},{26,24} }, "#f6e6bf") c:px(28, 19, "#c9a98a") c:px(29, 18, "#c9a98a")
D.fin()
