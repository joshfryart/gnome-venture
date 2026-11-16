-- Frostwart Bumps (pl-frt-4), yard sprite 64x64. Four frosty warts that go bump in the cold.
-- quirk: each wart tips a small ice spike (cream sparkle).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("pl-frt-4-yard", 64)

c:groundShadow(32, 57, 14, 2)
c:part(c:rect(22, 51, 26, 54), "stone")
c:part(c:rect(37, 51, 41, 54), "stone")
c:part(c:ellipse(32, 40, 16, 12), "sky")
local warts = c:ellipse(19, 33, 4, 4)
warts:add(c:ellipse(28, 28, 4, 4))
warts:add(c:ellipse(37, 28, 4, 4))
warts:add(c:ellipse(46, 33, 4, 4))
c:part(warts, "dusk")
c:eyeLocked(25, 39)
c:eyeLocked(34, 39)
c:fillMask(c:rect(30, 46, 33, 47), P.ink)
c:sparkle(19, 28)
c:sparkle(28, 22)
c:sparkle(37, 22)
c:sparkle(46, 27)
H.save(c, "pl-frt-4-yard")
