local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-cooking-pan: black iron frying pan with a wooden handle, fried egg inside.
-- quirk: the yolk is heart-shaped.
local c = D.new("ico-cooking-pan")
local IRON = { "#15111c", "#2a2438", "#403a54", "#5a536f", "#7a7392", "#a8a2bd" }
D.lit(c:line({ { 38, 36 }, { 59, 48 } }, 5), D.BRN, 2, { nopec = true })
D.fill(c:rect(56, 46, 57, 47), D.INK)
local pan = D.ell(24, 33, 19, 15, 0)
D.lit(pan, IRON, 8)
local inner = D.ell(24, 33, 15, 11, 0)
D.fill(inner, IRON[1])
D.fill(D.ell(24, 34, 14, 10), IRON[2])
D.px(14, 26, IRON[5]) D.px(15, 26, IRON[5]) D.px(13, 28, IRON[4])
-- egg white (wobbly)
local white = D.ell(24, 34, 11, 8, 0.15):add(D.ell(18, 36, 5, 4)):add(D.ell(30, 38, 5, 3))
D.lit(white, D.CREAM, 3)
-- heart yolk
local yolk = c:poly{ { 21, 30 }, { 22, 28 }, { 24, 29 }, { 26, 28 }, { 28, 30 }, { 24, 36 } }:add(c:rect(22, 29, 26, 31))
D.lit(yolk, D.ORG, 2.2)
D.px(22, 30, D.CR) D.px(23, 30, D.CR)
-- steam curl
D.fill(c:line({ { 34, 20 }, { 37, 16 }, { 34, 12 }, { 37, 8 } }, 2), D.CREAM[5])
D.fin()
