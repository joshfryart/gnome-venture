-- Snorkel Snip (cs-snorkel-snip), perch sprite 36x36. Haiku pass, c08. Hand-built at this size.
-- quirk: the snorkel tube and the two shells held up.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("cs-snorkel-snip-perch", 36)

c:groundShadow(18, 33, 8, 1.5)
c:part(c:ellipse(13, 31, 3, 2), "petal")
c:part(c:ellipse(23, 31, 3, 2), "petal")
c:part(c:line({ { 11, 25 }, { 5, 19 } }, 2), "petal")
c:part(c:line({ { 25, 25 }, { 31, 19 } }, 2), "petal")
c:part(c:ellipse(4, 16, 3, 3), "gold")
c:part(c:ellipse(32, 16, 3, 3), "gold")
c:part(c:ellipse(18, 23, 8, 7), "petal")
c:part(c:line({ { 22, 17 }, { 25, 7 } }, 2), "sea")
c:eyeSmall(13, 19)
c:eyeSmall(20, 19)
c:fillMask(c:line({ { 15, 26 }, { 18, 27 }, { 21, 26 } }, 1), P.ink)

H.done(c, "cs-snorkel-snip-perch")
