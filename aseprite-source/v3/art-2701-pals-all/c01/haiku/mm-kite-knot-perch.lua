-- Kite Knot (mm-kite-knot), perch sprite 36x36. Haiku first pass, c01. Ember kite, bow tail, huffy brows.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_haiku.lua")
local c = H.canvas("mm-kite-knot-perch", 36)
local P = H.P

c:groundShadow(18, 33, 8, 1)
c:part(c:line({ { 18, 27 }, { 17, 32 } }, 1), "dusk", { noshade = true })
c:part(c:poly { { 17, 30 }, { 13, 28 }, { 13, 33 } }, "petal", { band = 1 })
c:part(c:poly { { 17, 30 }, { 21, 28 }, { 21, 33 } }, "petal", { band = 1 })
local kite = c:poly { { 18, 3 }, { 31, 17 }, { 18, 28 }, { 5, 17 } }
c:part(kite, "ember", { band = 2 })
c:stitch({ { 18, 3 }, { 31, 17 }, { 18, 28 }, { 5, 17 }, { 18, 3 } })
c:part(c:line({ { 18, 5 }, { 18, 26 } }, 1), "dusk", { noshade = true })
c:eyeSmall(12, 14)
c:eyeSmall(21, 14)
c:px(11, 11, P.ink) c:px(12, 12, P.ink)
c:px(24, 11, P.ink) c:px(23, 12, P.ink)
c:px(13, 22, P.ink) c:px(14, 21, P.ink) c:px(15, 22, P.ink) c:px(16, 21, P.ink) c:px(17, 22, P.ink)
c:part(c:ellipse(30, 6, 2, 1), "sky", { band = 1 })

H.done(c, "mm-kite-knot-perch")
