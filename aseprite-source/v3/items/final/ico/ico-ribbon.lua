local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA8.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-ribbon: pink gift bow with two fat loops, a round knot and two forked tails.
-- quirk: the left tail has a frayed, uneven notch and the knot wears a tiny gold button.
local c = D.new("ico-ribbon")
local tails = c:poly{ {26, 30}, {20, 56}, {25, 52}, {29, 57}, {32, 34} }
D.lit(c, tails, D.PINK, 4, { amb = 0.12 })
local t2 = c:poly{ {32, 32}, {35, 57}, {40, 51}, {45, 55}, {38, 30} }
D.lit(c, t2, D.PINK, 4, { amb = 0.12 })
local ll = D.ell(17, 22, 12, 9, 0.35):cut(D.ell(18, 23, 5, 3, 0.35))
local rl = D.ell(47, 22, 12, 9, -0.35):cut(D.ell(46, 23, 5, 3, -0.35))
D.lit(c, ll, D.PINK, 6, { amb = 0.08 })
D.lit(c, rl, D.PINK, 6, { amb = 0.08 })
D.lit(c, D.ell(18, 23, 5, 3, 0.35), D.PINK, 2, { amb = 0.4 })
D.lit(c, D.ell(46, 23, 5, 3, -0.35), D.PINK, 2, { amb = 0.4 })
for _, p in ipairs{ {18, 23}, {19, 24}, {20, 24}, {44, 24}, {45, 24}, {46, 23} } do c:px(p[1], p[2], D.PINK[1]) end
local knot = c:rrect(27, 18, 37, 30, 3)
D.lit(c, knot, D.PINK, 4, { amb = 0.05 })
D.pts(c, { {10, 17}, {11, 16}, {12, 15}, {13, 15} }, D.PINK[6])
c:fillMask(c:ellipse(32, 24, 1.5, 1.5), D.YEL[4]) c:px(31, 23, CREAM)
D.fin()
