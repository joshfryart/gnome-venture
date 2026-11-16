-- Gander Gait (bb-gander-gait), yard sprite 64x64. Haiku pass, c02 (worklist chunk 2).
-- Wayfinder, common. A white goose with a gold beak and feet, a keyhole crest, marching right.
-- quirk: three small chicks march in a neat line behind it, expecting everyone to follow.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("gander-gait-yard", 64)

local GEESE = { "#aaa9b8", "#d6d4dc", "#e2e0e6", "#fff4d6" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local STONE = { "#74758c", "#aaa9b8", "#e2e0e6" }

c:groundShadow(32, 58, 17, 3)

-- quirk: three chicks marching behind
O.shade(c, c:ellipse(6, 53, 2, 2), GOLD, { R = 1, sep = GOLD[1] })
O.shade(c, c:ellipse(12, 54, 2, 2), GOLD, { R = 1, sep = GOLD[1] })
O.shade(c, c:ellipse(18, 53, 2, 2), GOLD, { R = 1, sep = GOLD[1] })
O.dots(c, { { 5, 56 }, { 11, 57 }, { 17, 56 } }, GOLD[1])

-- feet
O.flat(c, c:rect(27, 50, 28, 55), GOLD[2], "leg")
O.flat(c, c:rect(34, 50, 35, 55), GOLD[2], "leg")
O.dots(c, { { 25, 55 }, { 26, 55 }, { 33, 55 }, { 34, 55 }, { 35, 55 } }, GOLD[1])

-- tail
O.shade(c, c:poly{ { 14, 35 }, { 7, 30 }, { 12, 41 } }, GEESE, { R = 1, sep = GEESE[2] })

-- body and neck
local body = c:ellipse(29, 41, 16, 10)
O.shade(c, body, GEESE, { sphere = { 26, 37, 14 }, sep = GEESE[1] })
local nt, nn = O.tube({ { 39, 38 }, { 43, 30 }, { 43, 20 }, { 41, 14 } }, function(t) return 4 - .5 * t end)
O.shadeN(c, nt, nn, GEESE, { amb = .2, wrap = .35, sep = GEESE[1] })

-- head with keyhole crest
local head = c:ellipse(41, 11, 5, 4)
O.shade(c, head, GEESE, { sphere = { 40, 9, 5 }, sep = GEESE[1] })
O.shade(c, c:ellipse(40, 4, 2, 2), GEESE, { R = 1, sep = GEESE[1] })
O.dots(c, { { 40, 3 }, { 40, 4 }, { 40, 5 } }, P.ink)

-- beak and nose
O.shade(c, c:poly{ { 45, 9 }, { 53, 11 }, { 45, 13 } }, GOLD, { R = 1, sep = GOLD[1] })
O.dot(c, 46, 11, GOLD[1])

-- face: locked eye, cheek, smile line
c:eyeLocked(38, 9)
c:cheek(41, 14)
O.dots(c, { { 44, 13 } }, GOLD[1])

O.done(c, "gander-gait-yard")
