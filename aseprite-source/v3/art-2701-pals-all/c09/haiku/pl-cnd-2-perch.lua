-- Ledge Feather (pl-cnd-2), perch sprite 36x36, hand-built at this size. Quirk: dotted route trail.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local c = H.canvas("pl-cnd-2-perch", 36)

c:part(c:poly{ { 27, 2 }, { 33, 12 }, { 30, 24 }, { 21, 31 }, { 17, 27 }, { 23, 17 } }, "wood")
c:eyeSmall(25, 12)
c:px(12, 30, H.P.cream)
c:px(8, 33, H.P.cream)
c:px(5, 31, H.P.cream)
H.save(c, "pl-cnd-2-perch")
