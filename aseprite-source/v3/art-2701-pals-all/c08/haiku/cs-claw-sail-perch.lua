-- Claw Sail (cs-claw-sail), perch sprite 36x36. Haiku pass, c08. Hand-built at this size.
-- quirk: the sky-blue sail is a crab claw.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("cs-claw-sail-perch", 36)

c:groundShadow(18, 32, 9, 1.5)
c:part(c:line({ { 10, 28 }, { 6, 31 } }, 1), "ember")
c:part(c:line({ { 26, 28 }, { 30, 31 } }, 1), "ember")
c:part(c:line({ { 16, 24 }, { 16, 6 } }, 1), "wood")
local sail = c:ellipse(23, 9, 5, 4)
sail:cut(c:poly{ { 24, 7 }, { 30, 4 }, { 30, 12 } })
c:part(sail, "sky")
c:part(c:ellipse(18, 25, 9, 5), "ember")
c:part(c:ellipse(7, 25, 2, 2), "ember")
c:part(c:ellipse(29, 25, 2, 2), "ember")
c:eyeSmall(13, 21)
c:eyeSmall(20, 21)
c:fillMask(c:line({ { 11, 27 }, { 15, 29 }, { 21, 29 }, { 25, 27 } }, 1), P.ink)

H.done(c, "cs-claw-sail-perch")
