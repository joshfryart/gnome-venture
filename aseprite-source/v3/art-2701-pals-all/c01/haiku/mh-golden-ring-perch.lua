-- Golden Ring (mh-golden-ring), perch sprite 36x36. Haiku pass, c01. Hand-built at this size.
-- quirk: a pumpkin-shaped hole with a dark gold rim.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-golden-ring-perch", 36)

local GOLD = { "#5c3a14", "#8f5a1e", "#c98a2a", "#f0b448", "#ffd978", "#fff0b0" }
local INK  = P.ink

c:groundShadow(18, 33, 13, 2)

local hole = c:ellipse(18, 14, 5, 4)
hole:add(c:ellipse(14, 15, 2, 3))
hole:add(c:ellipse(22, 15, 2, 3))
local ring = c:ellipse(18, 18, 13, 13):copy():cut(hole)
local rb = {}
ring:each(function(x, y)
  if (x + y) % 3 == 0 then rb[K(x, y)] = -1 end
end)
O.shade(c, ring, GOLD, { R = 4, bias = rb })
O.flat(c, hole:copy():grow(1):clip(ring), GOLD[1], "rim")

c:eyeSmall(15, 24)
c:eyeSmall(20, 24)
O.dot(c, 18, 27, GOLD[1])
O.dots(c, { {16,28},{17,29},{18,29},{19,29},{20,28} }, GOLD[1])

O.done(c, "mh-golden-ring-perch")
