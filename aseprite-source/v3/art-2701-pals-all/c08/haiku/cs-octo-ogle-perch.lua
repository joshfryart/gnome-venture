-- Octo Ogle (cs-octo-ogle), perch sprite 36x36. Haiku pass, c08. Hand-built at this size.
-- quirk: a gold trinket held at a tentacle tip, sparkling.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("cs-octo-ogle-perch", 36)

c:groundShadow(18, 33, 8, 1.5)
local tent = c:line({ { 12, 19 }, { 9, 26 }, { 7, 31 } }, 2)
tent:add(c:line({ { 16, 20 }, { 15, 27 }, { 13, 33 } }, 2))
tent:add(c:line({ { 20, 20 }, { 21, 27 }, { 23, 33 } }, 2))
tent:add(c:line({ { 25, 19 }, { 28, 26 }, { 29, 30 } }, 2))
c:part(tent, "dusk")
c:part(c:ellipse(18, 13, 8, 7), "dusk")
c:part(c:ellipse(30, 31, 2, 2), "gold")
c:sparkle(33, 27)
c:eyeSmall(13, 10)
c:eyeSmall(21, 10)
c:fillMask(c:line({ { 16, 18 }, { 19, 18 } }, 1), P.ink)

H.done(c, "cs-octo-ogle-perch")
