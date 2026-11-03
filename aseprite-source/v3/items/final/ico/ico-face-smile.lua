local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-face-smile: round yellow face, big open smile, bold eyes and blush.
-- quirk: a tiny front tooth and a wink on the right eye.
local c = D.new("ico-face-smile")
local f = D.disc(32, 32, 22)
D.lit(f, D.YEL, 18, { amb = 0.05 })
c:fillMask(c:rect(20, 20, 22, 26), INK) c:px(20, 20, CR)
D.poly(c, { {37,24},{40,21},{44,21},{47,24} }, INK) D.poly(c, { {37,25},{40,22},{44,22},{47,25} }, INK)
local mouth = c:poly{ {17,35},{47,35},{43,45},{32,49},{21,45} }
D.fill(mouth, "#7a2036")
D.fill(c:rect(21, 36, 42, 37), "#7a2036")
D.fill(c:rect(29, 36, 32, 39), "#fff4d6")
D.fill(c:ellipse(32, 46, 6, 2), "#e8493b")
D.poly(c, { {17,35},{47,35} }, INK)
c:cheek(13, 36) c:cheek(14, 37) c:cheek(48, 36) c:cheek(47, 37)
D.fin()
