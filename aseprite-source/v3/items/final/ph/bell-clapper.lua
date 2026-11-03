-- bell-clapper: iron bell clapper (ball, flared neck, rod, eye-ring). quirk: a bit of red twine is tied through the ring and left trailing.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("bell-clapper")
local I = D.IRON
D.sh(32, 55, 11, 2)
-- ring: ellipse outline thick 2
local ring = D.ell(32, 12, 7, 5.5, 0):cut(D.ell(32, 12, 3.6, 2.6, 0))
D.lit(ring, I, 2.2, { wrap = .4 })
-- rod
local rod = c:rect(31, 17, 33, 38)
D.vc(rod, I, 31, 33)
-- collar
local col = c:poly{ {29,36}, {35,36}, {37,40}, {27,40} }
D.lit(col, I, 2)
for x = 29, 35 do c:px(x, 36, I[6]) end
-- ball
local ball = D.ell(32, 47, 8, 8, 0)
D.lit(ball, I, 5, { wrap = .3 })
c:px(28, 43, "#e8e8f8") c:px(29, 43, "#e8e8f8") c:px(28, 44, I[6])
for x = 26, 38 do if ball:has(x, 50) then end end
-- seam line round the ball
for a = 0, 3.14, .1 do local x, y = floor(32 + cos(a) * 7.4 + .5), floor(47 + sin(a) * 2.2 + .5) if ball:has(x, y) then c:px(x, y, I[2]) end end
-- rust fleck on collar
c:px(30, 38, "#a05a30")
-- twine through ring
for _, p in ipairs{ {26,9}, {25,10}, {25,11}, {24,12}, {24,13}, {23,14}, {22,15}, {22,17}, {21,19}, {22,21}, {21,23} } do c:px(p[1], p[2], "#e8493b") end
for _, p in ipairs{ {26,10}, {26,11}, {25,12}, {25,13}, {24,14} } do c:px(p[1], p[2], "#b52e3f") end
D.fin()
