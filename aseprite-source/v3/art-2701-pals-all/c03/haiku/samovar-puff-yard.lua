-- Samovar Puff (bb-samovar-puff), yard sprite 64x64. Haiku pass, c03.
-- Brewroot, common. Brass samovar with a chimney, a left handle, a drip spout and a saucer.
-- quirk: tea drips from the spout onto a saucer.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("samovar-puff-yard", 64)

local BRASS = { "#5a2e14", "#8c4a1f", "#b97a2a", "#d98322", "#f5b82e", "#ffe38a" }
local TEA   = { "#3a1a0e", "#5a2e14", "#8c4a1f" }
local STEAM = { "#74758c", "#aaa9b8", "#c8c6d2", "#e2e0e6" }

c:groundShadow(32, 58, 17, 3)

-- feet
O.flat(c, c:rect(20, 53, 25, 56), BRASS[2], "foot")
O.flat(c, c:rect(39, 53, 44, 56), BRASS[2], "foot")

-- steam wisps above the chimney
O.shade(c, c:ellipse(28, 5, 2, 2), STEAM, { R = 1, sep = STEAM[1] })
O.shade(c, c:ellipse(36, 4, 2, 2), STEAM, { R = 1, sep = STEAM[1] })

-- chimney with lip
O.shade(c, c:rrect(29, 9, 35, 23, 2), BRASS, { R = 2, sep = BRASS[1] })
O.shade(c, c:ellipse(32, 9, 4, 2), BRASS, { R = 1, sep = BRASS[1] })

-- body
local body = c:ellipse(32, 40, 15, 13)
O.shade(c, body, BRASS, { sphere = { 27, 33, 15 }, amb = .2, wrap = .35, sep = BRASS[1] })
-- collar band at the neck
local collar = c:ellipse(32, 27, 10, 3)
O.shade(c, collar, BRASS, { R = 1, sep = BRASS[1] })

-- left handle loop
local hm, hn = O.tube({ { 18, 34 }, { 10, 33 }, { 9, 43 }, { 18, 44 } }, function(t) return 1.3 end)
O.shadeN(c, hm, hn, BRASS, { amb = .3, sep = BRASS[1] })

-- drip spout, low on the right
local sm, sn = O.tube({ { 45, 44 }, { 49, 44 }, { 51, 41 }, { 54, 39 } }, function(t) return 2.2 - 0.8 * t end)
O.shadeN(c, sm, sn, BRASS, { amb = .3, sep = BRASS[1] })

-- quirk: tea drips onto the saucer
O.shade(c, c:ellipse(54, 51, 4, 1), BRASS, { R = 1, sep = BRASS[1] })
O.dots(c, { { 54, 42 }, { 54, 45 }, { 54, 48 } }, TEA[3])
O.dot(c, 54, 41, TEA[2])

-- face: locked eyes, cheeks, smile
c:eyeLocked(25, 36)
c:eyeLocked(36, 36)
c:cheek(22, 41)
c:cheek(39, 41)
O.dots(c, { { 28, 43 }, { 29, 44 }, { 30, 44 }, { 31, 44 }, { 32, 44 }, { 33, 44 }, { 34, 43 } }, P.ink)

-- brass rivet dots on the body
O.dots(c, { { 19, 46 }, { 45, 46 }, { 32, 51 } }, BRASS[6])

O.done(c, "samovar-puff-yard")
