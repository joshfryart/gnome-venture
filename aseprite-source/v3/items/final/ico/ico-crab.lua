local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA3.lua")
local HP, X = D.HP, D.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local INK, CR = D.INK, D.CR
-- ico-crab: bold red crab front view, two raised claws, eye stalks, stubby legs.
-- quirk: the left claw holds a tiny pearl.
local c = D.new("ico-crab")
local legs = { { { 18, 42 }, { 8, 44 }, { 6, 52 } }, { { 20, 47 }, { 12, 52 }, { 11, 58 } }, { { 46, 42 }, { 56, 44 }, { 58, 52 } }, { { 44, 47 }, { 52, 52 }, { 53, 58 } } }
for _, l in ipairs(legs) do c:part(c:line(l, 3), D.RED and { hi = D.RED[5], base = D.RED[3], shade = D.RED[2], deep = D.RED[1] }, { noshade = true, nopop = true }) end
-- arms
c:part(c:line({ { 18, 36 }, { 12, 28 } }, 4), { hi = D.RED[5], base = D.RED[3], shade = D.RED[2], deep = D.RED[1] }, { noshade = true, nopop = true })
c:part(c:line({ { 46, 36 }, { 52, 28 } }, 4), { hi = D.RED[5], base = D.RED[3], shade = D.RED[2], deep = D.RED[1] }, { noshade = true, nopop = true })
-- claws: ball with a V gap
local lc = D.disc(11, 19, 8):cut(c:poly{ { 11, 19 }, { 6, 8 }, { 12, 8 } })
local rc = D.disc(53, 19, 8):cut(c:poly{ { 53, 19 }, { 58, 8 }, { 52, 8 } })
D.lit(lc, D.RED, 5) D.lit(rc, D.RED, 5)
D.lit(D.disc(9, 11, 1.6), D.CREAM, 1) -- pearl
-- body
local body = D.ell(32, 40, 17, 11)
D.lit(body, D.RED, 7)
-- eyes on stalks
D.fill(c:rect(24, 24, 25, 29), D.RED[2]) D.fill(c:rect(39, 24, 40, 29), D.RED[2])
for _, x in ipairs{ 24, 39 } do D.fill(c:rect(x - 1, 21, x + 2, 24), D.CR) D.fill(c:rect(x, 22, x + 1, 24), D.INK) D.px(x, 22, D.CR) end
-- smile
D.fill(c:line({ { 27, 44 }, { 32, 47 }, { 37, 44 } }, 1), D.RED[1])
D.px(24, 36, D.RED[6]) D.px(25, 36, D.RED[6])
D.fin()
