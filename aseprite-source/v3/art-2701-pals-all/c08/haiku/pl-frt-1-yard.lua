-- Rime Crumb (pl-frt-1), yard sprite 64x64. Haiku pass, c08.
-- Common, rootwarden. A crumb of frost the frost toad coughed up: a sky-blue faceted lump with stubby feet.
-- quirk: it is still croaking, mouth open.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("pl-frt-1-yard", 64)

c:groundShadow(32, 58, 12, 2.5)
c:part(c:ellipse(24, 52, 4, 3), "sky")
c:part(c:ellipse(40, 52, 4, 3), "sky")
local body = c:poly{ { 20, 40 }, { 18, 28 }, { 24, 20 }, { 36, 20 }, { 44, 26 }, { 46, 40 }, { 38, 46 }, { 26, 46 } }
c:part(body, "sky")
c:fillMask(c:line({ { 30, 22 }, { 34, 30 }, { 30, 40 } }, 1), P.sky.deep)
c:sparkle(24, 30)
c:sparkle(41, 38)
c:px(37, 25, P.cream)
c:eyeLocked(24, 27)
c:eyeLocked(35, 27)
c:fillMask(c:ellipse(32, 41, 2, 1.5), P.ink)

H.done(c, "pl-frt-1-yard")
