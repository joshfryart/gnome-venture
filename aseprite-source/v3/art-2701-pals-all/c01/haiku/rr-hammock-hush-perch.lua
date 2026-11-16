-- Hammock Hush (rr-hammock-hush), perch sprite 36x36. Haiku first pass, c01. Upside-down moss pal in a gold hammock.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("rr-hammock-hush-perch", 36)
local P = H.P

c:part(c:line({ { 1, 3 }, { 35, 5 } }, 2), "wood")
c:part(c:line({ { 12, 5 }, { 11, 12 } }, 1), "wood", { noshade = true })
c:part(c:line({ { 24, 5 }, { 25, 12 } }, 1), "wood", { noshade = true })
c:part(c:ellipse(18, 19, 9, 10), "moss", { band = 2 })
c:part(c:poly { { 9, 19 }, { 27, 19 }, { 25, 24 }, { 18, 26 }, { 11, 24 } }, "gold", { band = 1 })
c:eyeSmall(13, 13)
c:eyeSmall(22, 13)
c:px(16, 23, P.ink) c:px(17, 23, P.ink) c:px(18, 23, P.ink) c:px(19, 23, P.ink)
c:cloud(26, 15, 8, P.sky.hi)
c:px(28, 11, P.ink) c:px(31, 11, P.ink)

H.done(c, "rr-hammock-hush-perch")
