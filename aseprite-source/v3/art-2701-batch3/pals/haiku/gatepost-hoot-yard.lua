-- Gatepost Hoot (mm-gatepost-hoot), yard sprite 64x64. Haiku pass, art-2701-batch3.
-- Seedkeeper, rare. A brown owl with ear tufts and a cream facial disc, perched on a wooden gatepost.
-- quirk: a ring of sky-blue hoot marks hanging over the post.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("gatepost-hoot-yard", 64)

local OWL  = { "#51302b", "#864c33", "#b97a4a", "#d9a070", "#e8b982" }
local CRM  = { "#c08a66", "#d9a982", "#ecc7a0", "#f7e0bd", "#fdeccc" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local POST = { "#51302b", "#864c33", "#b97a4a", "#d9a070", "#e8b982", "#f5d6a8" }
local SKY  = { "#5f9ad0", "#8bc4ea", "#b9e2f5" }

-- body and wings
local body = c:ellipse(32, 40, 15, 13)
O.shade(c, body, OWL, { sphere = { 28, 37, 14 }, amb = .2, wrap = .3, sep = OWL[1] })
local wings = c:ellipse(20, 40, 4, 8)
wings:add(c:ellipse(44, 40, 4, 8))
O.shade(c, wings, OWL, { R = 2, amb = .25, sep = OWL[1] })
O.mark(c, { { 20, 36 }, { 19, 40 }, { 21, 44 }, { 44, 36 }, { 45, 40 }, { 43, 44 } }, OWL[2])

-- ear tufts
O.shade(c, c:poly{ { 21, 13 }, { 19, 4 }, { 27, 10 } }, OWL, { R = 1, amb = .2 })
O.shade(c, c:poly{ { 43, 13 }, { 45, 4 }, { 37, 10 } }, OWL, { R = 1, amb = .2 })

-- head and cream facial disc
local head = c:ellipse(32, 22, 13, 12)
O.shade(c, head, OWL, { sphere = { 29, 18, 13 }, amb = .2, wrap = .3, sep = OWL[1] })
local disc = c:ellipse(32, 22, 10, 9)
disc:cut(c:rect(0, 31, 63, 63))
O.shade(c, disc, CRM, { R = 4, amb = .35, sep = CRM[1] })

-- eyes, beak, cheeks
c:eyeLocked(20, 19)
c:eyeLocked(39, 19)
O.shade(c, c:poly{ { 30, 25 }, { 34, 25 }, { 32, 29 } }, GOLD, { R = 1, amb = .2, sep = GOLD[1] })

-- gatepost: cap and post, with grain lines
O.shade(c, c:rect(23, 48, 41, 50), POST, { R = 1, amb = .2, sep = POST[1] })
local post = c:rect(26, 51, 38, 63)
O.shade(c, post, POST, { R = 3, amb = .25, sep = POST[1] })
O.mark(c, { { 29, 54 }, { 29, 55 }, { 29, 56 }, { 35, 58 }, { 35, 59 }, { 35, 60 } }, POST[2])
O.dots(c, { { 26, 58 }, { 38, 58 } }, POST[4])
-- talons gripping the cap
O.dots(c, { { 25, 49 }, { 39, 49 } }, GOLD[2])

-- quirk: hoot marks above
O.dots(c, { { 50, 8 }, { 51, 8 }, { 49, 9 }, { 52, 9 }, { 50, 10 }, { 51, 10 } }, SKY[2])
O.dots(c, { { 54, 16 }, { 55, 16 } }, SKY[3])

O.done(c, "gatepost-hoot-yard")
