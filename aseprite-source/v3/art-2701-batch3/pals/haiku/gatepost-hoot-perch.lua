-- Gatepost Hoot (mm-gatepost-hoot), perch sprite 36x36. Haiku pass, hand-built at this size.
-- quirk: the hoot ring over the post, here a 3x3 ring of sky dots.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("gatepost-hoot-perch", 36)

local OWL  = { "#51302b", "#864c33", "#b97a4a", "#d9a070" }
local CRM  = { "#c08a66", "#d9a982", "#ecc7a0", "#f7e0bd" }
local POST = { "#51302b", "#864c33", "#b97a4a", "#d9a070", "#e8b982" }
local SKY  = { "#5f9ad0", "#8bc4ea" }

c:groundShadow(18, 33, 8, 1)

-- post with cap
O.shade(c, c:rect(13, 26, 22, 27), POST, { R = 1, amb = .2, sep = POST[1] })
O.shade(c, c:rect(15, 28, 21, 33), POST, { R = 2, amb = .25, sep = POST[1] })

-- body and head
local body = c:ellipse(18, 20, 8, 7)
body:cut(c:rect(0, 27, 35, 35))
O.shade(c, body, OWL, { sphere = { 16, 18, 8 }, amb = .2, wrap = .3, sep = OWL[1] })
O.shade(c, c:poly{ { 12, 7 }, { 11, 1 }, { 15, 4 } }, OWL, { R = 1, amb = .2 })
O.shade(c, c:poly{ { 24, 7 }, { 25, 1 }, { 21, 4 } }, OWL, { R = 1, amb = .2 })
local head = c:ellipse(18, 11, 7, 7)
head:cut(c:rect(0, 18, 35, 35))
O.shade(c, head, OWL, { sphere = { 16, 9, 7 }, amb = .2, wrap = .3, sep = OWL[1] })
local disc = c:ellipse(18, 10, 5, 4)
disc:cut(c:rect(0, 14, 35, 35))
O.shade(c, disc, CRM, { R = 2, amb = .35, sep = CRM[1] })

c:eyeSmall(14, 9)
c:eyeSmall(20, 9)
O.dot(c, 18, 12, "#f5b82e") -- beak

-- wings
O.mark(c, { { 13, 21 }, { 14, 23 }, { 23, 21 }, { 22, 23 } }, OWL[2])

-- quirk: hoot ring
O.dots(c, { { 27, 2 }, { 28, 2 }, { 29, 2 }, { 27, 3 }, { 29, 3 }, { 27, 4 }, { 28, 4 }, { 29, 4 } }, SKY[2])

O.done(c, "gatepost-hoot-perch")
