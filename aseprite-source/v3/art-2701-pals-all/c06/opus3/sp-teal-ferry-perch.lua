-- Teal Ferry (sp-teal-ferry), perch sprite 36x36. Opus richness pass (c06/opus3), hand-built at this size.
-- Same design as the yard, fewer and bolder parts: teal pal in a straw cone hat, sitting in a canoe with an
-- upswept bow and marigolds, on a small bounded patch of river. Face: c:eyeSmall pills, smile, cheeks.
-- Richness: ring rows on the straw hat, a plank seam and lit gunwale on the hull, a hull reflection and lit
-- crests on the water, a lit belly on the fish.
-- quirk: it waves, and a small fish leaping by the bow waves its fin back.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("sp-teal-ferry-perch", 36)

local TEAL = { "#173c48", "#1f5e66", "#2a8486", "#43a8a2", "#74c8bc", "#b4e6d8" }
local RIV  = { "#1c4a5e", "#236a7a", "#2e8a92", "#4aaeae", "#86d0c8", "#c6ece2" }
local WOOD = { "#3a2422", "#5e3a2a", "#86573a", "#ad7c4f", "#cfa36c", "#ead0a0" }
local STRAW= { "#6e4a22", "#9a6a2c", "#c8963c", "#e4be5c", "#f6dc8a" }
local FISH = { "#7a2a1c", "#c4501e", "#f08030", "#ffb45a", "#ffe0a0" }

local riv = c:ellipse(18, 29, 16, 3.5)
local rb = {} riv:each(function(x, y) rb[K(x, y)] = (y == 29 and x % 7 < 2) and 2 or -1 end)
local rI, rT = O.shade(c, riv, RIV, { R = 2, amb = .35, wrap = .4, bias = rb })
O.tex(c, rI, rT, RIV, function(x, y, i) if y >= 29 and y <= 30 and x >= 6 and x <= 29 and x % 4 ~= 0 then return -1 end end)

local body = c:ellipse(14, 19, 7, 6.5)
O.shade(c, body, TEAL, { sphere = { 11, 16, 9 }, amb = .26, wrap = .35, rim = true, sep = TEAL[1] })
local hat = c:poly{ { 5, 14 }, { 23, 14 }, { 14, 6 } }
local hI, hT = O.shade(c, hat, STRAW, { sphere = { 12, 9, 9 }, amb = .3, wrap = .4, sep = STRAW[1], rim = true, cuts = { .22, .42, .62, .82 } })
O.tex(c, hI, hT, STRAW, function(x, y, i) if y % 3 == 0 and y < 14 then return -1 end if y == 14 and x % 2 == 0 then return -1 end end)
c:eyeSmall(10, 16) c:eyeSmall(16, 16)
O.dots(c, { { 12, 20 }, { 13, 21 }, { 14, 21 }, { 15, 20 } }, P.ink)
c:cheek(8, 20) c:cheek(18, 20)
local arm, an = O.tube({ { 20, 21 }, { 23, 19 }, { 24, 16 }, { 25, 13 } }, function(t) return 1.2 end)
O.shadeN(c, arm, an, TEAL, { amb = .3, sep = TEAL[1] })
O.shade(c, c:ellipse(25, 12, 1.5, 1.5), TEAL, { R = 1, amb = .4, sep = TEAL[1] })

local hull = c:poly{ { 2, 22 }, { 5, 25 }, { 28, 25 }, { 33, 20 }, { 33, 22 }, { 29, 29 }, { 7, 29 }, { 3, 25 } }
local wb = {} hull:each(function(x, y) wb[K(x, y)] = (y == 25) and 1 or -1 end)
O.shade(c, hull, WOOD, { R = 1, amb = .26, wrap = .4, bias = wb, sep = WOOD[1], rim = true })
hull:each(function(x, y) if y == 27 and x % 7 ~= 2 then c.pix[y * c.w + x] = WOOD[2] end end)
O.dots(c, { { 12, 26 }, { 22, 26 } }, WOOD[6])
O.dots(c, { { 5, 23 }, { 26, 23 } }, "#f8a628") O.dots(c, { { 6, 23 }, { 27, 23 } }, "#e0701e")
O.dots(c, { { 24, 23 } }, "#f6a2b8")
local lap = c:ellipse(17, 29.5, 13, 1) lap:cut(c:rect(0, 0, 35, 28))
O.shade(c, lap, RIV, { R = 1, amb = .45, sep = RIV[2] })

-- quirk: leaping fish waving a fin back
O.shade(c, c:ellipse(30, 12, 2.5, 1.5), FISH, { R = 1, amb = .4, sep = FISH[1], cuts = { .22, .42, .62, .82 } })
O.dots(c, { { 33, 11 }, { 33, 13 }, { 34, 10 }, { 34, 14 } }, FISH[3])
O.dots(c, { { 30, 9 }, { 30, 10 } }, FISH[4]) O.dots(c, { { 29, 13 }, { 30, 13 } }, FISH[5])
O.dot(c, 28, 11, P.ink)

O.shift(c, 0, -1)
O.done(c, "sp-teal-ferry-perch")
