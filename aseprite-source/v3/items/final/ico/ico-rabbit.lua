local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-rabbit: pale blue-grey rabbit face with tall ears, pink inner ears, a pink nose, whiskers and two front teeth.
-- quirk: the right ear flops over, bent at the middle.
local c = D.new("ico-rabbit")
local GR = { "#6a7aa0", "#8a9cc0", "#b0c0dc", "#cdd8ec", "#e4ecf8", "#f6f9ff" }
local el = D.ell(23, 17, 5, 13, -0.1)
D.lit(c, el, GR, 5, { amb = 0.15 })
D.lit(c, D.ell(23, 18, 2, 9, -0.1), D.PINK, 2)
-- floppy ear
local er = c:rrect(38, 8, 44, 24, 3)
D.lit(c, er, GR, 3, { amb = 0.15 })
D.lit(c, D.ell(50, 22, 7, 4, 0.5), GR, 3, { amb = 0.15 })
D.lit(c, D.ell(50, 22, 5, 2, 0.5), D.PINK, 1)
local body = c:ellipse(32, 52, 13, 8)
D.lit(c, body, GR, 6)
local head = c:ellipse(32, 40, 17, 14)
D.lit(c, head, GR, 10, { amb = 0.1 })
c:eyeSmall(23, 35) c:eyeSmall(39, 35)
c:cheek(20, 42) c:cheek(41, 42)
local sn = c:ellipse(32, 44, 5, 4)
D.lit(c, sn, GR, 3)
D.rect(c, 30, 41, 33, 42, D.PINK[3]) c:px(30, 41, D.PINK[6]) D.rect(c, 31, 42, 32, 42, D.PINK[2])
D.pts(c, { {32, 43}, {32, 44}, {30, 45}, {34, 45} }, INK)
D.rect(c, 30, 46, 31, 49, CREAM) D.rect(c, 33, 46, 34, 49, CREAM)
D.rect(c, 32, 46, 32, 49, GR[1])
D.pts(c, { {14, 42}, {13, 43}, {50, 42}, {51, 43} }, GR[1])
D.fin()
