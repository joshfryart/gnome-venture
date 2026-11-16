-- Slushbelly (bb-slushbelly), yard sprite 64x64. Haiku pass, c02 (worklist chunk 2).
-- Seedkeeper, common. A round pale-blue slush creature slumping into a puddle, with a seed on its snowball knob.
-- quirk: a drip runs down from one eye (it melts a little whenever someone looks).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("slushbelly-yard", 64)

local SKY   = { "#5f9ad0", "#8bc4ea", "#b9e2f5", "#e4f6ff" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local SEA   = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }

-- puddle it is melting into
local puddle = c:ellipse(32, 54, 22, 5)
O.shade(c, puddle, SEA, { R = 2, sep = SEA[1] })

-- snowball knob with a seed on it
O.shade(c, c:ellipse(32, 21, 4, 3), SKY, { R = 1, sep = SKY[2] })
O.dots(c, { { 33, 19 }, { 34, 19 }, { 33, 20 } }, WOOD[2])

-- slumped body with drips at the bottom
local body = c:ellipse(32, 37, 16, 15)
body:cut(c:rect(0, 49, 63, 63))
O.shade(c, body, SKY, { sphere = { 28, 32, 14 }, sep = SKY[1] })
O.shade(c, c:rect(18, 46, 21, 52), SKY, { R = 1, sep = SKY[1] })
O.shade(c, c:rect(42, 46, 45, 50), SKY, { R = 1, sep = SKY[1] })

-- face: locked eyes (sleepy, low), cheeks, nose, wobbly mouth
c:eyeLocked(23, 34)
c:eyeLocked(36, 34)
c:cheek(18, 41)
c:cheek(42, 41)
O.dots(c, { { 31, 39 }, { 32, 39 } }, SKY[1])
O.dots(c, { { 28, 43 }, { 29, 44 }, { 30, 43 }, { 31, 44 }, { 32, 43 }, { 33, 44 }, { 34, 43 } }, P.ink)

-- quirk: one drip running from the left eye
O.dots(c, { { 24, 39 }, { 24, 40 }, { 23, 41 } }, SKY[2])

O.done(c, "slushbelly-yard")
