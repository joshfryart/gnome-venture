-- Grotto Glim (cs-grotto-glim), perch sprite 36x36. Haiku pass, c08. Hand-built at this size.
-- quirk: glow spots and an "ooh" mouth.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("cs-grotto-glim-perch", 36)

c:groundShadow(18, 33, 8, 1.5)
c:part(c:line({ { 16, 8 }, { 12, 2 } }, 1), "dusk")
c:px(12, 1, P.gold.hi)
c:part(c:ellipse(18, 26, 8, 5), "dusk")
c:part(c:ellipse(18, 18, 7, 5), "dusk", { sep = true })
c:px(12, 24, P.gold.hi)
c:px(24, 22, P.gold.hi)
c:sparkle(7, 17)
c:eyeSmall(14, 14)
c:eyeSmall(20, 14)
c:fillMask(c:ellipse(18, 19, 1, 1), P.ink)

H.done(c, "cs-grotto-glim-perch")
