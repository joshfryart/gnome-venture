-- Puddle Croak (pl-frt-2), perch sprite 36x36. Haiku pass, c08. Hand-built at this size.
-- quirk: a music note drifting off its hum.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("pl-frt-2-perch", 36)

c:part(c:ellipse(18, 30, 13, 3), "sea")
c:part(c:ellipse(8, 29, 3, 2), "moss")
c:part(c:ellipse(28, 29, 3, 2), "moss")
c:part(c:ellipse(18, 24, 9, 6), "moss")
c:part(c:ellipse(18, 19, 8, 5), "moss", { sep = true })
c:eyeSmall(12, 15)
c:eyeSmall(21, 15)
c:cheek(11, 20)
c:cheek(22, 20)
c:fillMask(c:line({ { 13, 22 }, { 18, 24 }, { 23, 22 } }, 1), P.ink)
c:part(c:ellipse(31, 8, 1, 1), "gold")
c:fillMask(c:line({ { 32, 7 }, { 32, 3 } }, 1), P.gold.shade)

H.done(c, "pl-frt-2-perch")
