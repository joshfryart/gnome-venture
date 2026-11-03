local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-crystal-ball: glass sphere on a gold claw stand, violet-blue swirl inside, bright rim glints.
-- quirk: a tiny orange fish swims inside the ball.
local c = D.new("ico-crystal-ball")
c:groundShadow(32, 58, 17, 2)
-- stand
D.lit(c:poly{ { 16, 56 }, { 20, 46 }, { 44, 46 }, { 48, 56 } }, D.GOLD, 5)
D.fill(c:rect(18, 46, 46, 47), D.GOLD[1])
D.fill(c:rect(15, 55, 49, 57), D.GOLD[2])
-- ball
local ball = D.disc(32, 28, 20)
local PUR = { "#2a1f5c", "#3d3a8a", "#5a5fc0", "#7a8ae0", "#a8bcf2", "#d8e6ff" }
D.lit(ball, PUR, 12)
D.radial(ball, 32, 28, 17, 19.5, PUR[3])
-- swirl
D.fill(c:line({ { 22, 34 }, { 28, 22 }, { 38, 20 }, { 42, 28 } }, 2), PUR[2])
D.fill(c:line({ { 26, 38 }, { 36, 40 }, { 44, 34 } }, 1), PUR[5])
-- fish
D.lit(D.ell(34, 30, 4, 2.4), D.ORG, 2)
D.fill(c:poly{ { 37, 30 }, { 41, 27 }, { 41, 33 } }, D.ORG[2])
D.px(32, 29, D.INK)
-- glints
D.fill(c:rect(22, 14, 25, 15), D.CR) D.fill(c:rect(20, 16, 21, 20), D.CR) D.px(44, 40, PUR[6])
D.fin()
