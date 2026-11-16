-- Keel Drift (cs-keel-drift), perch sprite 36x36. Haiku pass, c08. Hand-built at this size.
-- quirk: the wink.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("cs-keel-drift-perch", 36)

c:groundShadow(18, 31, 11, 2)
c:part(c:ellipse(9, 27, 2, 2), "moss")
c:part(c:ellipse(24, 27, 2, 2), "moss")
c:part(c:poly{ { 6, 22 }, { 3, 24 }, { 6, 25 } }, "moss")
c:part(c:ellipse(29, 17, 4, 3), "moss")
local shell = c:ellipse(16, 20, 11, 8)
c:part(shell, "moss", { band = 2 })
c:fillMask(shell:edge(), P.gold.base)
c:fillMask(c:line({ { 10, 16 }, { 16, 20 }, { 22, 16 } }, 1), P.moss.deep)
c:px(11, 13, P.cream)
c:sparkle(31, 7)
c:eyeSmall(27, 15)
c:fillMask(c:line({ { 31, 18 }, { 33, 17 } }, 1), P.ink)

H.done(c, "cs-keel-drift-perch")
