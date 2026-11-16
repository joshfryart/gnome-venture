-- Thawdrop Pip (pl-frt-3), yard sprite 64x64. Meltwater drop with a tiny yawn.
-- quirk: the mouth is a little open yawn (the drop saved from the toad's last yawn).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("pl-frt-3-yard", 64)

c:groundShadow(32, 57, 12, 2)
local body = c:ellipse(32, 40, 14, 13)
body:add(c:poly{ { 32, 12 }, { 20, 37 }, { 44, 37 } })
c:part(body, "sea")
c:eyeLocked(24, 38)
c:eyeLocked(36, 38)
c:fillMask(c:ellipse(32, 48, 3, 2.5), P.ink) -- yawn
c:sparkle(46, 26)
H.save(c, "pl-frt-3-yard")
