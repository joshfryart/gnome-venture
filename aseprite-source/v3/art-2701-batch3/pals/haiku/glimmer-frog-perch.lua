-- Glimmer Frog (rr-glimmer-frog), perch sprite 36x36. Haiku pass, hand-built at this size.
-- quirk: the glowing sea-blue belly, here a 6x2 band plus three glow spots.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("glimmer-frog-perch", 36)

local FROG = { "#24544a", "#2f7150", "#3f9150", "#7cc35a", "#c4e07a" }
local SEA  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }

c:groundShadow(18, 31, 10, 2)

O.shade(c, c:ellipse(8, 26, 2, 2), FROG, { R = 1, amb = .25, sep = FROG[1] })
O.shade(c, c:ellipse(28, 26, 2, 2), FROG, { R = 1, amb = .25, sep = FROG[1] })

local body = c:ellipse(18, 22, 10, 7)
O.shade(c, body, FROG, { sphere = { 15, 19, 9 }, amb = .15, wrap = .3, sep = FROG[1] })

O.shade(c, c:ellipse(12, 14, 3, 3), FROG, { R = 1, amb = .2, sep = FROG[1] })
O.shade(c, c:ellipse(24, 14, 3, 3), FROG, { R = 1, amb = .2, sep = FROG[1] })
c:eyeSmall(11, 12)
c:eyeSmall(23, 12)

local belly = c:ellipse(18, 25, 6, 3)
O.shade(c, belly, SEA, { R = 1, amb = .35, sep = SEA[2] })
O.dots(c, { { 12, 20 }, { 20, 18 }, { 24, 22 } }, SEA[4]) -- quirk: glow spots

O.dots(c, { { 13, 21 }, { 14, 22 }, { 15, 22 }, { 16, 22 }, { 17, 22 }, { 18, 22 }, { 19, 22 }, { 20, 22 }, { 21, 21 } }, P.ink)

O.done(c, "glimmer-frog-perch")
