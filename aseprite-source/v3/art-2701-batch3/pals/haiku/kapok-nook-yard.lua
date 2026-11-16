-- Kapok Nook (rr-kapok-nook), yard sprite 64x64. Haiku pass, art-2701-batch3.
-- Seedkeeper, common. A fluffy kapok seed-pod napping on a root, eyes shut, notched fluff edge.
-- quirk: a tiny wooden root door with a gold knob, set into the root under the pod.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("kapok-nook-yard", 64)

local FLUFF = { "#8c7aa0", "#b3a0c4", "#d3c4df", "#eadff0", "#f6eff8", "#fff4d6" }
local WOOD  = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local SKY   = { "#5f9ad0", "#8bc4ea", "#b9e2f5" }

c:groundShadow(32, 58, 20, 3)

-- root mound under the pod
local root = c:ellipse(32, 53, 19, 6)
root:cut(c:rect(0, 0, 63, 47))
O.shade(c, root, WOOD, { R = 3, amb = .2, sep = WOOD[1] })

-- fluffy pod body with notched rim
local body = c:ellipse(32, 38, 18, 14)
body:cut(c:rect(0, 51, 63, 63))
local e = body:edge()
e:each(function(x, y) if (x * 7 + y * 3) % 5 == 0 then body.s[K(x, y)] = nil end end)
O.shade(c, body, FLUFF, { sphere = { 28, 32, 16 }, amb = .2, wrap = .35, sep = FLUFF[1] })

-- quirk: tiny root door in the root with a gold knob
O.flat(c, c:rect(29, 53, 34, 57), WOOD[1])
O.dot(c, 33, 55, "#f5b82e")

-- closed eyes (arcs), cheeks, nose and a small sleepy mouth
O.dots(c, { { 22, 36 }, { 23, 37 }, { 24, 37 }, { 25, 36 } }, P.ink)
O.dots(c, { { 38, 36 }, { 39, 37 }, { 40, 37 }, { 41, 36 } }, P.ink)
c:cheek(18, 41) c:cheek(43, 41)
O.dots(c, { { 31, 38 }, { 32, 38 } }, FLUFF[1])
O.dots(c, { { 30, 40 }, { 31, 41 }, { 32, 41 }, { 33, 40 } }, P.ink)

-- snore Z (ambient)
O.dots(c, { { 49, 10 }, { 50, 10 }, { 51, 10 }, { 50, 11 }, { 49, 12 }, { 50, 12 }, { 51, 12 } }, SKY[2])

O.done(c, "kapok-nook-yard")
