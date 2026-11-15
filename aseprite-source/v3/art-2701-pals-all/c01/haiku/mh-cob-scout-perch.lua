-- Cob Scout (mh-cob-scout), perch sprite 36x36. Haiku pass, c01. Hand-built at this size.
-- quirk: a short counting stick with ticks, held in the husk.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-cob-scout-perch", 36)

local GOLD = { "#8f4a1f", "#b5652a", "#d98322", "#f5b82e", "#ffe38a", "#fff2b8" }
local HUSK = { "#24544a", "#3f9150", "#5aa657", "#7cc35a", "#a6d670", "#c4e07a" }
local WOOD = { "#51302b", "#864c33", "#b97a4a", "#e8b982", "#f3d2a0", "#f8e4c0" }
local INK  = P.ink

c:groundShadow(18, 33, 10, 2)

O.shade(c, c:poly{ {12,31},{5,26},{6,20},{13,26} }, HUSK, { R = 1 })
O.shade(c, c:poly{ {24,31},{31,26},{30,20},{23,26} }, HUSK, { R = 1 })

local cob = c:ellipse(18, 19, 7, 11)
local kb = {}
cob:each(function(x, y)
  if (x - 11) % 3 == 0 or y % 3 == 0 then kb[K(x, y)] = -1 end
end)
O.shade(c, cob, GOLD, { R = 4, bias = kb })
O.shade(c, c:poly{ {12,29},{13,24},{18,27},{17,31},{13,31} }, HUSK, { R = 1, sep = HUSK[1] })

-- little straw hat
O.shade(c, c:rrect(12, 1, 24, 5, 1), WOOD, { R = 2 })
O.shade(c, c:ellipse(18, 6, 10, 2), WOOD, { R = 1, sep = WOOD[1] })
O.dots(c, { {13,5},{14,5},{15,5},{16,5},{17,5},{18,5},{19,5},{20,5},{21,5},{22,5},{23,5} }, WOOD[1])

-- counting stick with ticks
local stick = c:line({ {24,27}, {30,12} }, 1)
O.flat(c, stick, WOOD[3])
O.dots(c, { {26,24},{27,22},{28,19},{29,17} }, WOOD[1])

c:eyeSmall(15, 17)
c:eyeSmall(20, 17)
O.dot(c, 18, 21, INK)
O.dots(c, { {16,23},{17,24},{18,24},{19,24} }, GOLD[1])

O.done(c, "mh-cob-scout-perch")
