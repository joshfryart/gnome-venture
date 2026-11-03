local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA2.lua")
local c = D.new("ico-clock")
local CR, INK, ell = D.CR, D.INK, D.ell
-- ico-clock: round wall clock, chunky wood rim, cream face with four bold ticks, red-tipped hands at 3:00 -ish, brass pin.
-- quirk: a tiny snail crawls along the bottom of the rim.
D.lit(c:ellipse(32, 30, 22, 22), D.WOODR, 11, { amb = 0.1 })
D.lit(c:ellipse(32, 30, 17, 17), D.CREAM, 9, { amb = 0.25 })
D.ring = nil
for _, p in ipairs{ {32, 15, 33, 19}, {32, 41, 33, 45}, {17, 30, 21, 31}, {43, 30, 47, 31} } do D.fill(c:rect(p[1] - 0, p[2], p[3], p[4]), "#51302b") end
D.px(24, 19, "#8a6a5a") D.px(40, 19, "#8a6a5a") D.px(24, 41, "#8a6a5a") D.px(40, 41, "#8a6a5a")
D.poly(c, { {32, 30}, {32, 21} }, INK) D.poly(c, { {33, 30}, {33, 21} }, INK)
D.lit(c:line({ {32, 30}, {42, 33} }, 3), D.RED, 1.5)
D.lit(ell(32.5, 30, 2.5, 2.5, 0), D.YEL, 2)
D.px(27, 22, D.CR)
-- snail
D.fill(c:rect(33, 56, 44, 58), "#f0b98d"); D.px(45, 55, "#f0b98d") D.px(46, 54, INK)
D.lit(ell(37, 54, 3.5, 3.5, 0), D.PINK, 3); D.px(36, 53, D.PINK[1]) D.px(37, 54, D.PINK[1])
D.fin()
