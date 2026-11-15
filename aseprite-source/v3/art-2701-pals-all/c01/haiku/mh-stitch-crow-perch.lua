-- Stitch Crow (mh-stitch-crow), perch sprite 36x36. Haiku pass, c01. Hand-built at this size.
-- quirk: a straw hat with a stitched band.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-stitch-crow-perch", 36)

local CROW = { "#2a2440", "#3a3058", "#4e4272", "#66588c", "#8a78b0", "#b4a4d4" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982", "#f3d2a0", "#f8e4c0" }
local BEAK = { "#8f4a1f", "#b5652a", "#d98322", "#f5b82e", "#ffd55a", "#ffe9a0" }
local INK  = P.ink

c:groundShadow(18, 33, 9, 2)

O.flat(c, c:line({ {16,28}, {15,32} }, 1), BEAK[2])
O.flat(c, c:line({ {20,28}, {21,32} }, 1), BEAK[2])
O.shade(c, c:poly{ {11,22},{4,28},{6,30},{13,25} }, CROW, { R = 1 })
O.shade(c, c:ellipse(16, 22, 7, 6), CROW, { R = 3, sep = CROW[1] })
O.shade(c, c:ellipse(19, 12, 5, 5), CROW, { R = 2, sep = CROW[1] })
c:stitch({ {12,21}, {17,19}, {23,21} })
O.shade(c, c:poly{ {23,11},{28,13},{23,15} }, BEAK, { R = 1, sep = BEAK[1] })
O.dot(c, 24, 12, INK)

-- little hat
O.shade(c, c:rrect(14, 0, 25, 4, 1), WOOD, { R = 1 })
O.shade(c, c:ellipse(19, 5, 7, 1), WOOD, { R = 1, sep = WOOD[1] })
O.dots(c, { {15,4},{16,4},{17,4},{18,4},{19,4},{20,4},{21,4},{22,4},{23,4} }, WOOD[1])

c:eyeSmall(17, 11)
c:eyeSmall(20, 11)
O.dots(c, { {17,10},{18,10},{20,10},{21,10} }, INK)

O.done(c, "mh-stitch-crow-perch")
