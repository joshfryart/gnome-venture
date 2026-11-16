-- Harbour Leap (ow-harbour-leap), yard sprite 64x64. Haiku pass, c02 (worklist chunk 2). RARE: a touch fancier.
-- Wayfinder, rare. A sea-blue dolphin leaping over a stone breakwater, gold fin edge and a gold hook at the top of the leap.
-- quirk: a ring of splash ripples lands in the bay below (the same bay every time).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("harbour-leap-yard", 64)

local SEA   = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local STONE = { "#444663", "#74758c", "#aaa9b8", "#e2e0e6" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local SKY   = { "#5f9ad0", "#8bc4ea", "#b9e2f5" }

-- breakwater across the bottom (behind the splash)
O.shade(c, c:rect(0, 54, 63, 63), STONE, { R = 3, sep = STONE[1] })

-- quirk: splash ripples in the bay
O.dots(c, { { 18, 56 }, { 19, 57 }, { 20, 56 }, { 44, 55 }, { 45, 56 }, { 46, 55 } }, SKY[2])

-- hook at the top of the leap (gold)
local hook, hn = O.tube({ { 31, 22 }, { 31, 14 }, { 35, 9 }, { 39, 11 } }, function(t) return 1 end)
O.shadeN(c, hook, hn, GOLD, { amb = .2, wrap = .35, sep = GOLD[1] })

-- leaping dolphin body: tube from tail to beak, thick in the middle
local body, bn = O.tube({ { 12, 50 }, { 22, 26 }, { 42, 24 }, { 54, 44 } }, function(t) return 1.5 + 6 * math.sin(math.pi * t) end)
O.shadeN(c, body, bn, SEA, { amb = .2, wrap = .35, sep = SEA[1] })

-- tail flukes
O.shade(c, c:poly{ { 10, 50 }, { 2, 45 }, { 4, 54 } }, SEA, { R = 1, sep = SEA[1] })

-- gold fin edge along the back
O.dots(c, { { 33, 17 }, { 36, 16 }, { 39, 17 } }, GOLD[3])

-- face: locked eye near the beak
c:eyeLocked(45, 33)
O.dots(c, { { 51, 42 }, { 52, 43 } }, SEA[1])
O.dots(c, { { 47, 41 }, { 48, 42 }, { 49, 42 } }, P.ink)

-- rare touch: sparkles
c:sparkle(12, 16)
c:sparkle(52, 14)

O.done(c, "harbour-leap-yard")
