local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-droplet: fat blue water drop with glossy highlights.
-- quirk: a tiny second droplet falls beside it, and a ripple ring waits underneath.
local c = D.new("ico-droplet")
D.fill(D.sub(D.ell(28, 59, 18, 3.4), D.ell(28, 59, 14, 1.4)), D.BLUE[3])
local d = D.disc(28, 37, 16):add(c:poly{ { 28, 4 }, { 14, 32 }, { 42, 32 } })
D.lit(d, D.BLUE, 9)
D.radial(d, 28, 38, 13.5, 15, D.BLUE[2])
D.fill(c:line({ { 18, 38 }, { 19, 44 }, { 23, 49 } }, 2), D.BLUE[6])
D.fill(c:rect(22, 24, 23, 26), D.CR) D.px(24, 22, D.CR)
D.px(35, 46, "#78d8e8")
-- little drop
local sd = D.disc(53, 28, 4):add(c:poly{ { 53, 18 }, { 49, 26 }, { 57, 26 } })
D.lit(sd, D.BLUE, 3)
D.px(52, 28, D.CR)
D.fin()
