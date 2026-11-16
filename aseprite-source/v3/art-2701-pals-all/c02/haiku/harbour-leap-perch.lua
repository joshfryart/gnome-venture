-- Harbour Leap (ow-harbour-leap), perch sprite 36x36. Haiku pass, c02 (worklist chunk 2). RARE: a touch fancier.
-- Wayfinder, rare. A sea-blue dolphin leaping over a breakwater, gold fin dots and a gold hook at the top of the leap.
-- quirk: splash ripples land in the bay below.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("harbour-leap-perch", 36)

local SEA   = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local STONE = { "#444663", "#74758c", "#aaa9b8" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local SKY   = { "#5f9ad0", "#8bc4ea", "#b9e2f5" }

-- breakwater across the bottom
O.shade(c, c:rect(0, 30, 35, 35), STONE, { R = 1, sep = STONE[1] })
O.dots(c, { { 7, 28 }, { 8, 28 }, { 28, 29 }, { 29, 29 } }, SKY[2])

-- gold hook at the top
local hook, hn = O.tube({ { 16, 10 }, { 16, 6 }, { 19, 4 }, { 21, 5 } }, function(t) return .6 end)
O.shadeN(c, hook, hn, GOLD, { amb = .2, wrap = .35, sep = GOLD[1] })

-- dolphin body from tail to beak
local body, bn = O.tube({ { 5, 30 }, { 10, 13 }, { 24, 12 }, { 31, 24 } }, function(t) return 1 + 4 * math.sin(math.pi * t) end)
O.shadeN(c, body, bn, SEA, { amb = .2, wrap = .35, sep = SEA[1] })
O.shade(c, c:poly{ { 5, 30 }, { 1, 26 }, { 2, 32 } }, SEA, { R = 1, sep = SEA[1] })

-- gold fin dots along the back
O.dots(c, { { 15, 11 }, { 18, 10 }, { 21, 11 } }, GOLD[3])

-- face: small eye near the beak
c:eyeSmall(25, 19)

-- rare touch: sparkles
c:sparkle(5, 8)
c:sparkle(31, 6)

O.done(c, "harbour-leap-perch")
