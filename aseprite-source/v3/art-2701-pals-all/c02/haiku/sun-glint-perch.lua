-- Sun Glint (ow-sun-glint), perch sprite 36x36. Haiku pass, c02 (worklist chunk 2), hand-built at this size.
-- quirk: a sparkle wink in place of the second eye.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("sun-glint-perch", 36)

local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

-- three rays on top
local function ray(pts, w0, w1)
  local m, n = O.tube(pts, function(t) return w0 + (w1 - w0) * t end)
  O.shadeN(c, m, n, GOLD, { amb = .2, wrap = .35, sep = GOLD[1] })
end
ray({ { 18, 15 }, { 18, 11 }, { 18, 8 }, { 18, 4 } }, 1.6, .4)
ray({ { 13, 18 }, { 10, 14 }, { 8, 11 }, { 6, 8 } }, 1.6, .4)
ray({ { 23, 18 }, { 26, 14 }, { 28, 11 }, { 30, 8 } }, 1.6, .4)

-- the disc
O.shade(c, c:ellipse(18, 21, 10, 10), GOLD, { sphere = { 15, 18, 9 }, sep = GOLD[1] })
O.dots(c, { { 1, 21 }, { 2, 21 }, { 34, 21 }, { 35, 21 } }, GOLD[2])

-- face: small eye, sparkle wink, cheeks, nose, smile
c:eyeSmall(13, 19)
c:sparkle(24, 20)
c:cheek(10, 24)
c:cheek(23, 24)
O.dots(c, { { 17, 22 }, { 18, 22 } }, GOLD[1])
O.dots(c, { { 15, 26 }, { 16, 27 }, { 17, 27 }, { 18, 27 }, { 19, 27 }, { 20, 26 } }, P.ink)

O.done(c, "sun-glint-perch")
