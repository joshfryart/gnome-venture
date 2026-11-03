local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-compass: round brass pocket compass, cream dial, red/white needle, loop ring on top.
-- quirk: a tiny ladybug rides on the rim.
local c = D.new("ico-compass")
D.lit(D.ring(32, 9, 6, 3), D.GOLD, 2)
local case = D.disc(32, 36, 22)
D.lit(case, D.GOLD, 6)
local dial = D.disc(32, 36, 17)
D.fill(dial, D.CREAM[2])
D.fill(D.disc(32, 36, 16), D.CREAM[5])
D.radial(dial, 32, 36, 14, 16, D.CREAM[4])
for i = 0, 3 do local a = i * pi / 2 c:fillMask(c:rect(floor(32 + cos(a) * 13) - 1, floor(36 + sin(a) * 13) - 1, floor(32 + cos(a) * 13), floor(36 + sin(a) * 13)), D.INK) end
-- needle (diagonal)
local nx, ny = 0.55, -0.83
local red = c:poly{ { 32 + nx * 14, 36 + ny * 14 }, { 32 - ny * 4, 36 + nx * 4 }, { 32 + ny * 4, 36 - nx * 4 } }
local wht = c:poly{ { 32 - nx * 14, 36 - ny * 14 }, { 32 - ny * 4, 36 + nx * 4 }, { 32 + ny * 4, 36 - nx * 4 } }
D.fill(wht, D.STEEL[4]) D.fill(red, D.RED[4])
D.px(34, 29, D.RED[6]) D.px(32, 36, D.GOLD[5]) D.px(33, 36, D.GOLD[3]) D.px(32, 37, D.GOLD[2])
-- ladybug
D.lit(D.ell(48, 17, 3.2, 2.8), D.RED, 2)
D.px(47, 17, D.INK) D.px(49, 16, D.INK) D.px(50, 18, D.INK) D.px(45, 16, D.INK)
D.fin()
