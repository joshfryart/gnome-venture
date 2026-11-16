-- Glimmer Frog (rr-glimmer-frog), yard sprite 64x64. Haiku pass, art-2701-batch3.
-- Wayfinder, rare. A green frog with bulging eyes on top of its head and a sea-blue glowing belly.
-- quirk: the glowing belly and the sea-blue glow spots on its back, which light up in rain.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("glimmer-frog-yard", 64)

local FROG = { "#24544a", "#2f7150", "#3f9150", "#7cc35a", "#c4e07a", "#e2f2a8" }
local SEA  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }

c:groundShadow(32, 57, 17, 3)

-- back legs, front legs
local back = c:ellipse(14, 47, 4, 3)
back:add(c:ellipse(50, 47, 4, 3))
O.shade(c, back, FROG, { R = 2, amb = .25, sep = FROG[1] })
local front = c:ellipse(22, 51, 3, 2)
front:add(c:ellipse(42, 51, 3, 2))
O.shade(c, front, FROG, { R = 1, amb = .25, sep = FROG[1] })

-- body
local body = c:ellipse(32, 40, 17, 12)
O.shade(c, body, FROG, { sphere = { 28, 34, 16 }, amb = .15, wrap = .3, sep = FROG[1] })

-- head bumps with eyes on top
O.shade(c, c:ellipse(20, 25, 5, 5), FROG, { R = 2, amb = .2, sep = FROG[1] })
O.shade(c, c:ellipse(44, 25, 5, 5), FROG, { R = 2, amb = .2, sep = FROG[1] })
c:eyeLocked(18, 23)
c:eyeLocked(42, 23)

-- glowing sea-blue belly
local belly = c:ellipse(32, 45, 10, 5)
O.shade(c, belly, SEA, { R = 2, amb = .35, sep = SEA[2] })
O.dots(c, { { 28, 45 }, { 36, 45 } }, SEA[4])

-- quirk: glow spots on the back
O.dots(c, { { 24, 36 }, { 29, 33 }, { 37, 34 }, { 41, 38 }, { 33, 40 } }, SEA[4])
c:sparkle(50, 16)
c:sparkle(12, 18)

-- wide smile with a nose dot
O.dots(c, { { 24, 36 }, { 25, 37 }, { 26, 38 }, { 27, 38 }, { 28, 38 }, { 29, 38 }, { 30, 38 }, { 31, 38 }, { 32, 38 }, { 33, 38 }, { 34, 38 }, { 35, 38 }, { 36, 38 }, { 37, 38 }, { 38, 37 }, { 39, 36 } }, P.ink)
O.dots(c, { { 31, 34 }, { 32, 34 } }, FROG[2])

O.done(c, "glimmer-frog-yard")
