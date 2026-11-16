-- Cocopaddle (ss-cocopaddle), perch sprite 36x36. Opus second pass, hand-built at this size:
-- deeper hull so the pill eyes, pore nose and grin all fit under the cream rim; palm-frond sail with
-- three leaflet grooves; paddle in front with the blade in the swell.
-- quirk: the message-in-a-bottle, here 4x2 with a cork.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("cocopaddle-perch", 36)

local HUSK = { "#3a2220", "#5e3628", "#865234", "#a8703f", "#c99254", "#e3b676" }
local MEAT = { "#c9b08e", "#e6d4b2", "#f6ead0", "#fff4d6" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local LEAF = { "#1f4a3c", "#2f6b46", "#3f9150", "#62b05a", "#93cc6a", "#c4e07a" }
local SEA  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#9ee4dc", "#d4f6ee" }
local GLAS = { "#3f9150", "#7cc35a", "#b6e0a0" }

local sea = c:ellipse(17, 31, 15, 2)
sea:cut(c:rect(0, 33, 35, 35))
O.shade(c, sea, SEA, { R = 1, amb = .35, cuts = { .3, .5, .7, .88 } })
O.dots(c, { { 4, 30 }, { 29, 30 } }, SEA[5])

-- mast + frond sail
O.shade(c, c:rect(17, 3, 18, 20), WOOD, { R = 1, amb = .3 })
local sail = c:poly{ { 19, 3 }, { 25, 5 }, { 29, 10 }, { 29, 16 }, { 25, 18 }, { 19, 18 } }
local lb = {}
sail:each(function(x, y) if (y - x * .6) % 4 < 1 and x > 20 then lb[K(x, y)] = -2 end end)
O.shade(c, sail, LEAF, { R = 2, bias = lb, amb = .2, wrap = .35, sep = LEAF[1] })

-- hull
local hull = c:ellipse(17, 20, 12, 10)
hull:cut(c:rect(0, 0, 35, 19))
local hb = {}
hull:each(function(x, y) if (x * 13 + y * 7) % 10 == 0 then hb[K(x, y)] = -1 end end)
O.shade(c, hull, HUSK, { sphere = { 13, 19, 14 }, bias = hb, amb = .2, wrap = .35 })
local rim = c:ellipse(17, 20, 12, 2)
rim:cut(c:rect(0, 0, 35, 18))
O.shade(c, rim, MEAT, { R = 1, amb = .45, cuts = { .3, .6, .85 } })
O.flat(c, c:ellipse(17, 19.5, 10, 1), HUSK[2], "hollow")
O.shade(c, c:rect(17, 18, 18, 20), WOOD, { R = 1, amb = .3 })

-- paddle + arm
local sh, shn = O.tube({ { 10, 13 }, { 8, 19 }, { 6, 24 }, { 5, 27 } }, function(t) return .7 end)
O.shadeN(c, sh, shn, WOOD, { amb = .35 })
O.shade(c, c:poly{ { 3, 26 }, { 7, 27 }, { 6, 31 }, { 4, 33 }, { 2, 30 } }, WOOD, { R = 1, amb = .3, sep = WOOD[1] })
O.dots(c, { { 10, 21 }, { 9, 20 }, { 9, 19 } }, HUSK[4]) O.dots(c, { { 9, 18 }, { 8, 18 } }, HUSK[5])

-- face
for _, ex in ipairs({ 12, 21 }) do -- pale coconut-flesh eye patches so the pills read on the dark husk
  local e = c:rect(ex - 1, 22, ex + 2, 26)
  e:cut(c:rect(ex - 1, 22, ex - 1, 22)) e:cut(c:rect(ex + 2, 22, ex + 2, 22)) e:cut(c:rect(ex - 1, 26, ex - 1, 26)) e:cut(c:rect(ex + 2, 26, ex + 2, 26))
  O.flat(c, e, MEAT[2], "eyewhite")
  c:eyeSmall(ex, 23)
end
O.dot(c, 9, 27, "#f5809f") O.dot(c, 25, 27, "#f5809f")
O.dots(c, { { 16, 25 }, { 17, 25 } }, HUSK[1]) O.dot(c, 16, 25, MEAT[2])
O.dots(c, { { 14, 27 }, { 15, 28 }, { 16, 28 }, { 17, 28 }, { 18, 28 }, { 19, 27 } }, P.ink)

-- quirk: bottle
O.flat(c, c:rect(28, 28, 31, 29), GLAS[2], "bottle")
O.dots(c, { { 28, 28 }, { 29, 28 } }, GLAS[3]) O.dot(c, 30, 28, MEAT[3]) O.dot(c, 31, 29, GLAS[1])
O.flat(c, c:rect(32, 28, 32, 29), WOOD[2], "cork")

O.done(c, "cocopaddle-perch")
