-- Barrow Peephole (pl-frt-5), perch sprite 36x36, hand-built at this size. Quirk: a small eye in the hole.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("pl-frt-5-perch", 36)

c:groundShadow(18, 32, 7, 1.5)
local door = c:rrect(9, 5, 27, 30, 2)
c:part(door, "wood")
c:fillMask(c:rect(18, 6, 18, 28):clip(door), P.wood.deep)
c:fillMask(c:rect(10, 6, 26, 6):clip(door), P.sky.hi)
local ring = c:ellipse(18, 16, 4, 4)
ring:cut(c:ellipse(18, 16, 3, 3))
c:part(ring, "stone")
c:fillMask(c:ellipse(18, 16, 3, 3), P.stone.deep)
c:eyeSmall(17, 15)
c:part(c:rect(23, 20, 24, 22), "stone")
H.save(c, "pl-frt-5-perch")
