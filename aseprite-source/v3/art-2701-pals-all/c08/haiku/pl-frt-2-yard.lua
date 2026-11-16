-- Puddle Croak (pl-frt-2), yard sprite 64x64. Haiku pass, c08.
-- Common, seedkeeper. A green toad sitting in a cold puddle, humming a lullaby for toads.
-- quirk: the little music notes drifting off its hum.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("pl-frt-2-yard", 64)

c:part(c:ellipse(32, 54, 26, 6), "sea")
c:part(c:ellipse(20, 48, 6, 4), "moss")
c:part(c:ellipse(44, 48, 6, 4), "moss")
c:part(c:ellipse(32, 40, 17, 13), "moss")
c:part(c:ellipse(32, 30, 14, 8), "moss", { sep = true })
c:px(14, 40, P.moss.deep)
c:px(48, 44, P.moss.deep)
c:px(40, 46, P.moss.hi)
c:eyeLocked(21, 22)
c:eyeLocked(37, 22)
c:cheek(16, 34)
c:cheek(42, 34)
c:fillMask(c:line({ { 26, 36 }, { 32, 39 }, { 38, 36 } }, 1), P.ink)
-- lullaby notes
c:part(c:ellipse(50, 22, 2, 1), "gold")
c:fillMask(c:line({ { 52, 21 }, { 52, 12 } }, 1), P.gold.shade)
c:part(c:ellipse(57, 14, 2, 1), "gold")
c:fillMask(c:line({ { 59, 13 }, { 59, 5 } }, 1), P.gold.shade)

H.done(c, "pl-frt-2-yard")
