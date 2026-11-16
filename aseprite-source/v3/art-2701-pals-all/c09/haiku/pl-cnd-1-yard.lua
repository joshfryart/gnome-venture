-- Crag Quill (pl-cnd-1), yard sprite 64x64. A bronze quill the condor dropped, and it thinks it is a spear.
-- quirk: a stone spearhead on the shaft tip and a sparkle on it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local c = H.canvas("pl-cnd-1-yard", 64)

c:groundShadow(32, 60, 8, 1.5)
local vane = c:poly{ { 32, 12 }, { 44, 30 }, { 40, 46 }, { 32, 54 }, { 24, 46 }, { 20, 30 } }
c:part(vane, "gold")
c:eyeLocked(25, 30)
c:eyeLocked(35, 30)
c:part(c:rect(31, 6, 33, 58), "stone")
c:part(c:poly{ { 28, 11 }, { 32, 1 }, { 36, 11 } }, "stone")
c:sparkle(38, 6)
H.save(c, "pl-cnd-1-yard")
