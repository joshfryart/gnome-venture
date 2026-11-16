-- Mate Mumble (rr-mate-mumble), yard sprite 64x64. Haiku pass, art-2701-batch3.
-- Brewroot, common. A dried gourd cup with a gold band, a moss sprout and a metal straw.
-- quirk: little music notes floating up from the straw while it hums.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mate-mumble-yard", 64)

local GOURD = { "#51302b", "#864c33", "#b97a4a", "#d9a070", "#e8b982", "#f5d6a8" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a", "#fff0b8" }
local STONE = { "#5a5b78", "#74758c", "#aaa9b8", "#c9c8d3", "#e2e0e6" }
local MOSS  = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local SKY   = { "#5f9ad0", "#8bc4ea", "#b9e2f5" }

c:groundShadow(30, 58, 15, 3)

-- gourd: bulb plus neck
local g = c:ellipse(32, 42, 15, 13)
g:add(c:ellipse(31, 25, 8, 9))
O.shade(c, g, GOURD, { sphere = { 28, 36, 16 }, amb = .15, wrap = .3, sep = GOURD[1] })

-- gold band around the middle
local band = g:copy()
band:clip(c:rect(0, 30, 63, 33))
O.shade(c, band, GOLD, { R = 1, amb = .25, sep = GOLD[1] })

-- moss sprout on the neck
O.shade(c, c:ellipse(24, 16, 4, 2), MOSS, { R = 1, amb = .2 })

-- metal straw
local straw = c:line({ { 43, 40 }, { 49, 28 }, { 51, 19 } }, 1.6)
O.shade(c, straw, STONE, { R = 1, amb = .3, sep = STONE[1] })

-- face: locked eyes, cheeks, a humming mouth, a little nose dot
c:eyeLocked(23, 35)
c:eyeLocked(37, 35)
c:cheek(21, 43) c:cheek(40, 43)
O.dots(c, { { 31, 40 }, { 32, 40 } }, GOURD[2])
O.dots(c, { { 29, 44 }, { 30, 45 }, { 31, 45 }, { 32, 45 }, { 33, 44 } }, P.ink)

-- quirk: humming notes rising from the straw
O.dots(c, { { 54, 10 }, { 55, 9 }, { 55, 8 }, { 56, 8 } }, SKY[2])
O.dots(c, { { 58, 15 }, { 59, 14 }, { 59, 13 } }, SKY[3])

O.done(c, "mate-mumble-yard")
