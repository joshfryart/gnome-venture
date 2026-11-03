local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA5.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local fl, ab = math.floor, math.abs
-- ico-hand-wave: tilted open hand with fanned fingers and motion arcs. quirk: a gold ring on the ring finger.
local c = D.new("ico-hand-wave")
local SK = { "#9a4f45", "#c9786a", "#e69a82", "#f4b79a", "#ffd2b4", "#ffe6cf" }
local m = D.c:rrect(20, 32, 42, 52, 5)
m:add(D.c:line({ { 22, 34 }, { 17, 18 } }, 5)):add(D.c:line({ { 28, 33 }, { 26, 13 } }, 5)):add(D.c:line({ { 35, 33 }, { 36, 14 } }, 5)):add(D.c:line({ { 40, 35 }, { 46, 22 } }, 5))
m:add(D.ell(17, 44, 4, 6, -.5)):add(D.ell(16, 40, 3, 5, -.9))
m:add(D.rect(24, 51, 38, 57))
local r = D.rot(m, 32, 45, -0.25):shift(-4, 0)
D.lit(r, SK, 5, { amb = 0.1 })
-- sleeve cuff
D.lit(D.rot(D.rect(22, 53, 40, 58), 32, 45, -0.25):shift(-4, 0), D.ORG, 3)
-- ring
D.fill(D.rect(41, 22, 44, 23), D.GOLD[4])
-- motion arcs (right top)
D.fill(D.c:line({ { 50, 8 }, { 56, 14 }, { 58, 22 } }, 2), D.BLUE[5])
D.fill(D.c:line({ { 46, 5 }, { 54, 6 }, { 60, 12 } }, 2), D.BLUE[4])
D.px(51, 8, D.CR)
D.fin()
