-- Kapok Nook (rr-kapok-nook), perch sprite 36x36. Haiku pass, hand-built at this size.
-- quirk: the tiny root door with a gold knob, here a 3x3 door at the foot of the pod.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("kapok-nook-perch", 36)

local FLUFF = { "#8c7aa0", "#b3a0c4", "#d3c4df", "#eadff0", "#f6eff8" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local SKY   = { "#5f9ad0", "#8bc4ea" }

c:groundShadow(18, 31, 12, 2)

local root = c:ellipse(18, 28, 10, 3)
root:cut(c:rect(0, 0, 35, 25))
O.shade(c, root, WOOD, { R = 2, amb = .2, sep = WOOD[1] })

local body = c:ellipse(18, 19, 11, 9)
body:cut(c:rect(0, 26, 35, 35))
local e = body:edge()
e:each(function(x, y) if (x * 5 + y * 3) % 6 == 0 then body.s[K(x, y)] = nil end end)
O.shade(c, body, FLUFF, { sphere = { 16, 16, 9 }, amb = .2, wrap = .35, sep = FLUFF[1] })

-- root door
O.flat(c, c:rect(16, 26, 19, 28), WOOD[1])
O.dot(c, 18, 27, "#f5b82e")

-- closed eyes, cheeks, nose, mouth
O.dots(c, { { 12, 18 }, { 13, 19 }, { 14, 18 } }, P.ink)
O.dots(c, { { 22, 18 }, { 23, 19 }, { 24, 18 } }, P.ink)
O.dots(c, { { 10, 21 }, { 25, 21 } }, "#f5809f")
O.dots(c, { { 17, 20 }, { 18, 20 } }, FLUFF[1])
O.dots(c, { { 16, 22 }, { 17, 23 }, { 18, 23 }, { 19, 22 } }, P.ink)

-- snore Z
O.dots(c, { { 28, 3 }, { 29, 3 }, { 30, 3 }, { 29, 4 }, { 28, 5 }, { 29, 5 }, { 30, 5 } }, SKY[2])

O.done(c, "kapok-nook-perch")
