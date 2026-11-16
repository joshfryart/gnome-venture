-- Jar Hum (ow-jar-hum), yard sprite 64x64. Haiku pass, c02 (worklist chunk 2).
-- Brewroot, common. A round terracotta oil jar with a cork peg stopper and a clay lip.
-- quirk: hum waves ripple out from both sides of the jar.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("jar-hum-yard", 64)

local TERRA = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local SKY   = { "#5f9ad0", "#8bc4ea", "#b9e2f5" }

c:groundShadow(32, 58, 15, 3)

-- hum waves either side (not outlined: drawn after finish)
O.dots(c, { { 9, 30 }, { 7, 33 }, { 9, 36 } }, SKY[2])
O.dots(c, { { 54, 30 }, { 56, 33 }, { 54, 36 } }, SKY[2])

-- neck and lip
local neck = c:rect(26, 18, 37, 26)
O.shade(c, neck, TERRA, { R = 1, sep = TERRA[1] })
O.flat(c, c:rect(23, 16, 40, 18), TERRA[3], "lip")

-- belly
local belly = c:ellipse(32, 40, 16, 15)
belly:cut(c:rect(0, 0, 63, 25))
O.shade(c, belly, TERRA, { sphere = { 28, 36, 14 }, sep = TERRA[1] })

-- cork peg stopper
O.shade(c, c:rect(29, 10, 34, 15), WOOD, { R = 1, sep = WOOD[1] })

-- face: locked eyes, cheeks, nose, hum mouth
c:eyeLocked(24, 38)
c:eyeLocked(35, 38)
c:cheek(20, 44)
c:cheek(40, 44)
O.dots(c, { { 31, 42 }, { 32, 42 } }, TERRA[4])
O.dots(c, { { 31, 46 }, { 32, 46 }, { 30, 47 }, { 33, 47 }, { 31, 48 }, { 32, 48 } }, P.ink)

O.done(c, "jar-hum-yard")
