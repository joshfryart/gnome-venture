-- Barrow Peephole (pl-frt-5), yard sprite 64x64. A peephole in the old barrow door, frosty round the edges.
-- quirk: an eye peers out through the peephole.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("pl-frt-5-yard", 64)

c:groundShadow(32, 58, 20, 2)
local door = c:rrect(14, 8, 50, 56, 4)
c:part(door, "wood")
c:fillMask(c:rect(23, 10, 23, 54):clip(door), P.wood.deep) -- plank seams
c:fillMask(c:rect(41, 10, 41, 54):clip(door), P.wood.deep)
c:fillMask(c:rect(15, 9, 49, 10):clip(door), P.sky.hi) -- frost along the top
local ring = c:ellipse(32, 30, 11, 11)
ring:cut(c:ellipse(32, 30, 8, 8))
c:part(ring, "stone")
local frost = c:ellipse(32, 30, 6, 6)
frost:cut(c:ellipse(32, 30, 5, 5))
c:fillMask(frost, P.sky.hi) -- frost ring round the hole
c:fillMask(c:ellipse(32, 30, 5, 5), P.stone.deep)
c:eyeLocked(30, 28)
c:part(c:rect(18, 38, 22, 40), "stone") -- latch
H.save(c, "pl-frt-5-yard")
