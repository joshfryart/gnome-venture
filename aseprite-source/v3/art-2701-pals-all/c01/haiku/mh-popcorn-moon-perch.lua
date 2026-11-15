-- Popcorn Moon (mh-popcorn-moon), perch sprite 36x36. Haiku pass, c01. Hand-built at this size.
-- quirk: popcorn bumps on the rim and a popped bit flying off.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mh-popcorn-moon-perch", 36)

local POP = { "#b89468", "#d9b98a", "#ecd6a8", "#f6e6c0", "#fbf1d6" }
local INK = P.ink

c:groundShadow(18, 33, 11, 2)

local moon = c:ellipse(18, 18, 13, 13):copy():cut(c:ellipse(24, 14, 10, 10))
local puffs = { {5,22},{5,13},{9,6},{16,4},{23,27} }
for _, p in ipairs(puffs) do moon:add(c:ellipse(p[1], p[2], 1, 1)) end
O.shade(c, moon, POP, { R = 3 })
O.shade(c, c:ellipse(4, 21, 1, 1), POP, { R = 0, sep = POP[1] })
O.shade(c, c:ellipse(9, 6, 1, 1), POP, { R = 0, sep = POP[1] })

c:eyeSmall(7, 17)
c:eyeSmall(11, 17)
O.dot(c, 9, 21, INK)
O.dots(c, { {7,24},{8,25},{9,25},{10,25},{11,24} }, "#6e2c2a")

O.dot(c, 30, 4, POP[5])
O.dot(c, 33, 9, POP[4])

O.done(c, "mh-popcorn-moon-perch")
