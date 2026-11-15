-- Highland Ring (rr-highland-ring), perch sprite 36x36. Haiku first pass, c01. Stone hoop, snow cap, summit flag.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("rr-highland-ring-perch", 36)
local P = H.P

c:groundShadow(18, 33, 11, 2)
c:part(c:rect(17, 1, 18, 9), "wood", { noshade = true })
c:part(c:poly { { 18, 2 }, { 25, 4 }, { 18, 6 } }, "ember", { noshade = true })
local outer = c:ellipse(18, 19, 12, 12)
local hole = c:ellipse(18, 17, 5, 4)
local hoop = outer:copy():cut(hole)
c:part(hoop, "stone", { band = 2 })
c:fillMask(hoop:copy():clip(c:rect(0, 0, 35, 11)), P.cream)
c:part(hole, "sky", { band = 1 })
c:eyeSmall(12, 24)
c:eyeSmall(22, 24)
c:px(16, 28, P.ink) c:px(17, 28, P.ink) c:px(18, 28, P.ink) c:px(19, 28, P.ink)

H.done(c, "rr-highland-ring-perch")
