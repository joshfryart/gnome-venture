local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-dove: white dove in flight, one big raised wing, fanned tail, orange beak.
-- quirk: it carries an olive sprig in its beak.
local c = D.new("ico-dove")
local W = { "#6a6a96", "#9494b8", "#c4c6e0", "#e6e8f4", "#f6f6fc", "#ffffff" }
W[6] = "#fffdf6"
-- far wing
D.lit(c:poly{ { 30, 32 }, { 14, 6 }, { 22, 6 }, { 36, 28 } }, W, 3)
-- tail
D.lit(c:poly{ { 20, 38 }, { 4, 44 }, { 6, 52 }, { 24, 46 } }, W, 2.5)
D.fill(c:line({ { 8, 46 }, { 18, 43 } }, 1), W[2])
-- body
D.lit(D.ell(32, 38, 14, 7, -0.25), W, 5)
-- near wing
local wing = c:poly{ { 26, 40 }, { 24, 10 }, { 34, 4 }, { 44, 14 }, { 40, 38 } }
D.lit(wing, W, 5)
for _, x in ipairs{ 28, 32, 36 } do D.fill(c:line({ { x, 12 + abs(x - 32) }, { x, 34 } }, 1), W[3]) end
-- head
D.lit(D.disc(46, 33, 5.5), W, 3)
D.fill(c:poly{ { 50, 32 }, { 57, 35 }, { 50, 37 } }, D.ORG[3])
D.px(47, 31, D.INK) D.px(46, 30, D.CR)
-- olive sprig
D.fill(c:line({ { 56, 35 }, { 60, 40 }, { 60, 50 } }, 1), "#3f9150")
D.lit(D.ell(57, 44, 2.4, 1.4, 1.0), "moss", 1.3) D.lit(D.ell(60, 47, 2.4, 1.4, -1.0), "moss", 1.3) D.lit(D.ell(57, 51, 2.4, 1.4, 1.0), "moss", 1.3)
D.fin()
