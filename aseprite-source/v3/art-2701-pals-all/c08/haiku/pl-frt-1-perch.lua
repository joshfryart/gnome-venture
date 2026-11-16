-- Rime Crumb (pl-frt-1), perch sprite 36x36. Haiku pass, c08. Hand-built at this size.
-- quirk: a croaking open mouth.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("pl-frt-1-perch", 36)

c:groundShadow(18, 32, 8, 1.5)
c:part(c:ellipse(12, 30, 2, 2), "sky")
c:part(c:ellipse(23, 30, 2, 2), "sky")
c:part(c:poly{ { 10, 25 }, { 9, 16 }, { 13, 10 }, { 21, 10 }, { 26, 15 }, { 27, 25 }, { 22, 29 }, { 14, 29 } }, "sky")
c:fillMask(c:line({ { 18, 12 }, { 20, 18 }, { 18, 24 } }, 1), P.sky.deep)
c:px(22, 14, P.cream)
c:px(13, 22, P.cream)
c:eyeSmall(12, 16)
c:eyeSmall(20, 16)
c:fillMask(c:ellipse(16, 23, 1, 1), P.ink)

H.done(c, "pl-frt-1-perch")
