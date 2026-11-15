-- Octo Ogle (cs-octo-ogle), yard sprite 64x64. Haiku pass, c08.
-- Common, wayfinder. A purple octopus with big ogling eyes, four tentacles and one fist around a shiny gold thing.
-- quirk: the shiny gold trinket it is staring at (sparkles on it), held at a tentacle tip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("cs-octo-ogle-yard", 64)

c:groundShadow(32, 60, 16, 2.5)
local tent = c:line({ { 20, 34 }, { 14, 44 }, { 10, 54 }, { 6, 60 } }, 4)
tent:add(c:line({ { 26, 36 }, { 24, 48 }, { 20, 56 }, { 18, 62 } }, 4))
tent:add(c:line({ { 32, 38 }, { 32, 50 }, { 28, 58 } }, 4))
tent:add(c:line({ { 38, 36 }, { 40, 48 }, { 44, 57 } }, 4))
tent:add(c:line({ { 44, 34 }, { 48, 42 }, { 50, 46 } }, 4))
c:part(tent, "dusk")
c:part(c:ellipse(32, 24, 16, 14), "dusk")
c:part(c:ellipse(51, 47, 3, 3), "gold")
c:sparkle(55, 41)
c:sparkle(47, 39)
c:eyeLocked(21, 21)
c:eyeLocked(37, 21)
c:fillMask(c:ellipse(32, 33, 2, 1.5), P.ink)
c:cheek(16, 30)
c:cheek(43, 30)

H.done(c, "cs-octo-ogle-yard")
