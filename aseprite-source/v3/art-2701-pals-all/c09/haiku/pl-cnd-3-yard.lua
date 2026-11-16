-- Updraft Fluff (pl-cnd-3), yard sprite 64x64. A puff of cream neck fluff that rides the wind to see the view.
-- quirk: two wind swirls trail round it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("pl-cnd-3-yard", 64)

local body = c:ellipse(32, 36, 16, 12)
body:add(c:ellipse(20, 30, 7, 7))
body:add(c:ellipse(33, 25, 8, 8))
body:add(c:ellipse(45, 30, 6, 6))
body:add(c:ellipse(26, 44, 6, 5))
c:part(body, "skinA")
c:eyeLocked(25, 36)
c:eyeLocked(35, 36)
c:fillMask(c:line({ { 2, 20 }, { 10, 18 }, { 16, 21 } }, 1), P.sky.base)
c:fillMask(c:line({ { 50, 50 }, { 58, 47 }, { 62, 50 } }, 1), P.sky.base)
H.save(c, "pl-cnd-3-yard")
