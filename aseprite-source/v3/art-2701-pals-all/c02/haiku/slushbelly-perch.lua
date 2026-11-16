-- Slushbelly (bb-slushbelly), perch sprite 36x36. Haiku pass, c02 (worklist chunk 2), hand-built at this size.
-- quirk: a drip runs down from the left eye.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("slushbelly-perch", 36)

local SKY   = { "#5f9ad0", "#8bc4ea", "#b9e2f5", "#e4f6ff" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a" }
local SEA   = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }

-- puddle it is melting into
O.shade(c, c:ellipse(18, 30, 12, 3), SEA, { R = 1, sep = SEA[1] })

-- snowball knob with a seed on it
O.shade(c, c:ellipse(18, 7, 2, 2), SKY, { R = 1, sep = SKY[2] })
O.dots(c, { { 19, 6 }, { 20, 6 } }, WOOD[2])

-- slumped body with drips
local body = c:ellipse(18, 18, 10, 9)
body:cut(c:rect(0, 27, 35, 35))
O.shade(c, body, SKY, { sphere = { 15, 14, 8 }, sep = SKY[1] })
O.shade(c, c:rect(9, 24, 10, 28), SKY, { R = 1, sep = SKY[1] })
O.shade(c, c:rect(25, 24, 26, 27), SKY, { R = 1, sep = SKY[1] })

c:eyeSmall(12, 17)
c:eyeSmall(21, 17)
c:cheek(8, 20)
c:cheek(24, 20)
O.dots(c, { { 17, 19 }, { 18, 19 } }, SKY[1])
O.dots(c, { { 14, 22 }, { 15, 23 }, { 16, 22 }, { 17, 23 }, { 18, 22 }, { 19, 23 }, { 20, 22 } }, P.ink)

-- quirk: a drip from the left eye
O.dots(c, { { 12, 19 }, { 11, 20 } }, SKY[2])

O.done(c, "slushbelly-perch")
