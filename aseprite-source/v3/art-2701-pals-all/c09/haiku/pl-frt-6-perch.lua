-- Barrow Icecrown (pl-frt-6), perch sprite 36x36, hand-built at this size. Quirk: croaking mouth under the crown.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("pl-frt-6-perch", 36)

local crown = c:poly{ { 9, 22 }, { 9, 14 }, { 13, 18 }, { 17, 10 }, { 21, 18 }, { 25, 10 }, { 27, 14 }, { 27, 22 } }
crown:add(c:rect(9, 20, 27, 22))
c:part(crown, "sky")
c:eyeSmall(13, 19)
c:eyeSmall(21, 19)
c:fillMask(c:rect(16, 25, 20, 25), P.ink)
c:sparkle(25, 7)
H.save(c, "pl-frt-6-perch")
