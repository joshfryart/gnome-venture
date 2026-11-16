-- Lagoon Loop (ss-lagoon-loop), perch sprite 36x36. Haiku first pass, c01. Gold ring, sea-blue hole, one wink.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("ss-lagoon-loop-perch", 36)
local P = H.P

c:groundShadow(18, 33, 11, 2)
local outer = c:ellipse(18, 18, 13, 13)
local hole = c:ellipse(18, 15, 5, 4)
c:part(outer:copy():cut(hole), "gold", { band = 2 })
c:part(hole, "sea", { band = 1 })
c:px(15, 14, P.sky.hi) c:px(16, 14, P.sky.hi)
c:eyeSmall(12, 23)
c:px(22, 25, P.ink) c:px(23, 24, P.ink)

H.done(c, "ss-lagoon-loop-perch")
