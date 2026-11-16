-- Crag Quill (pl-cnd-1), perch sprite 36x36, hand-built at this size. Quirk: stone spearhead on top.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local c = H.canvas("pl-cnd-1-perch", 36)

c:groundShadow(18, 33, 6, 1.5)
c:part(c:poly{ { 17, 7 }, { 23, 15 }, { 21, 24 }, { 17, 28 }, { 13, 24 }, { 11, 15 } }, "gold")
c:eyeSmall(13, 14)
c:eyeSmall(20, 14)
c:part(c:rect(17, 2, 18, 31), "stone")
c:part(c:poly{ { 15, 5 }, { 17, 0 }, { 20, 5 } }, "stone")
H.save(c, "pl-cnd-1-perch")
