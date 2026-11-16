-- Sun Glint (ow-sun-glint), yard sprite 64x64. Haiku pass, c02 (worklist chunk 2).
-- Rootwarden, uncommon. A gold sun disc with three rays on top, a locked eye and a sparkle wink.
-- quirk: the sparkle wink, a glint that stays on after the other eye is closed.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("sun-glint-yard", 64)

local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local SKY  = { "#5f9ad0", "#8bc4ea", "#b9e2f5" }

-- three rays (tri knob) on top, behind the disc
local function ray(pts, w0, w1)
  local m, n = O.tube(pts, function(t) return w0 + (w1 - w0) * t end)
  O.shadeN(c, m, n, GOLD, { amb = .2, wrap = .35, sep = GOLD[1] })
end
ray({ { 32, 22 }, { 32, 16 }, { 32, 11 }, { 32, 6 } }, 2.4, .6)
ray({ { 25, 24 }, { 20, 18 }, { 16, 14 }, { 13, 11 } }, 2.4, .6)
ray({ { 39, 24 }, { 44, 18 }, { 48, 14 }, { 51, 11 } }, 2.4, .6)

-- the disc
local disc = c:ellipse(32, 36, 17, 17)
O.shade(c, disc, GOLD, { sphere = { 28, 31, 16 }, sep = GOLD[1] })

-- small rays around the disc (dots)
O.dots(c, { { 5, 36 }, { 6, 36 }, { 58, 36 }, { 59, 36 }, { 32, 56 }, { 32, 57 } }, GOLD[2])

-- face: locked eye, sparkle wink, cheeks, nose, smile
c:eyeLocked(23, 33)
c:sparkle(37, 34)
c:cheek(19, 40)
c:cheek(42, 40)
O.dots(c, { { 31, 39 }, { 32, 39 } }, GOLD[1])
O.dots(c, { { 28, 42 }, { 29, 43 }, { 30, 43 }, { 31, 43 }, { 32, 43 }, { 33, 43 }, { 34, 42 } }, P.ink)

O.done(c, "sun-glint-yard")
