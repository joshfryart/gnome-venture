-- Barrow Icecrown (pl-frt-6), yard sprite 64x64. The frost toad's spare crown of ice, still croaking.
-- quirk: the crown has a croaking mouth below its band, and gems set in the band.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("pl-frt-6-yard", 64)

local crown = c:poly{ { 18, 40 }, { 18, 22 }, { 23, 31 }, { 27, 18 }, { 32, 29 }, { 37, 18 }, { 41, 31 }, { 46, 22 }, { 46, 40 } }
crown:add(c:rect(18, 36, 46, 46))
c:part(crown, "sky")
c:part(c:ellipse(32, 43, 2.5, 2.5), "dusk")
c:part(c:ellipse(24, 43, 1.5, 1.5), "petal")
c:part(c:ellipse(40, 43, 1.5, 1.5), "petal")
c:eyeLocked(21, 38)
c:eyeLocked(38, 38)
c:fillMask(c:ellipse(32, 51, 3, 1.5), P.ink)
c:sparkle(27, 14)
c:sparkle(37, 14)
c:sparkle(18, 20)
H.save(c, "pl-frt-6-yard")
