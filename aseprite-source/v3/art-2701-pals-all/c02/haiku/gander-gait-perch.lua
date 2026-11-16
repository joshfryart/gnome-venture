-- Gander Gait (bb-gander-gait), perch sprite 36x36. Haiku pass, c02 (worklist chunk 2), hand-built at this size.
-- quirk: three small chicks march in a line behind it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("gander-gait-perch", 36)

local GEESE = { "#aaa9b8", "#d6d4dc", "#e2e0e6", "#fff4d6" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

c:groundShadow(18, 32, 9, 2)

-- quirk: three chicks behind
O.dots(c, { { 2, 29 }, { 3, 29 }, { 2, 30 }, { 3, 30 } }, GOLD[3])
O.dots(c, { { 6, 30 }, { 7, 30 }, { 6, 31 }, { 7, 31 } }, GOLD[3])
O.dots(c, { { 10, 29 }, { 11, 29 }, { 10, 30 }, { 11, 30 } }, GOLD[3])

-- feet
O.flat(c, c:rect(13, 26, 14, 30), GOLD[2], "leg")
O.flat(c, c:rect(20, 26, 21, 30), GOLD[2], "leg")

-- tail, body, neck, head
O.shade(c, c:poly{ { 9, 20 }, { 4, 16 }, { 7, 23 } }, GEESE, { R = 1, sep = GEESE[2] })
O.shade(c, c:ellipse(14, 21, 8, 5), GEESE, { sphere = { 12, 19, 7 }, sep = GEESE[1] })
local nt, nn = O.tube({ { 21, 19 }, { 24, 14 }, { 24, 8 }, { 23, 5 } }, function(t) return 2.5 - .5 * t end)
O.shadeN(c, nt, nn, GEESE, { amb = .2, wrap = .35, sep = GEESE[1] })
O.shade(c, c:ellipse(23, 4, 3, 3), GEESE, { sphere = { 22, 3, 3 }, sep = GEESE[1] })
O.shade(c, c:poly{ { 25, 3 }, { 30, 4 }, { 25, 5 } }, GOLD, { R = 1, sep = GOLD[1] })

-- face: small eye, cheek, smile
c:eyeSmall(21, 3)
c:cheek(23, 6)
O.dot(c, 25, 4, GOLD[1])

O.done(c, "gander-gait-perch")
