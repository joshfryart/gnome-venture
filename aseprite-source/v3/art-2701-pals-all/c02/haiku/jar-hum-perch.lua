-- Jar Hum (ow-jar-hum), perch sprite 36x36. Haiku pass, c02 (worklist chunk 2), hand-built at this size.
-- quirk: hum waves ripple out from both sides of the jar.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("jar-hum-perch", 36)

local TERRA = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local SKY   = { "#5f9ad0", "#8bc4ea" }

c:groundShadow(18, 32, 9, 2)

-- hum waves either side
O.dots(c, { { 5, 18 }, { 3, 20 }, { 5, 22 } }, SKY[2])
O.dots(c, { { 31, 18 }, { 33, 20 }, { 31, 22 } }, SKY[2])

-- cork peg stopper, lip, neck and belly
O.shade(c, c:rect(16, 4, 19, 8), WOOD, { R = 1, sep = WOOD[1] })
O.flat(c, c:rect(12, 8, 23, 9), TERRA[3], "lip")
O.shade(c, c:rect(14, 10, 21, 14), TERRA, { R = 1, sep = TERRA[1] })
local belly = c:ellipse(18, 22, 10, 9)
O.shade(c, belly, TERRA, { sphere = { 15, 19, 8 }, sep = TERRA[1] })

c:eyeSmall(13, 20)
c:eyeSmall(22, 20)
c:cheek(10, 24)
c:cheek(24, 24)
O.dots(c, { { 17, 23 }, { 18, 23 } }, TERRA[4])
O.dots(c, { { 16, 26 }, { 17, 27 }, { 18, 27 }, { 19, 26 } }, P.ink)

O.done(c, "jar-hum-perch")
