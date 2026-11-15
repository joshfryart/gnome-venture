-- Flamingo Flick (th-flamingo-flick), perch 36x36. Hand-built at size. Haiku first pass.
-- quirk: the raised dare-wing (see yard).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "th-flamingo-flick-perch" }
c:part(c:rect(2, 31, 33, 34), "sea", { band = 1 })
c:part(c:line({ { 15, 24 }, { 16, 31 } }, 2), "ember")
c:part(c:ellipse(16, 20, 7, 5), "petal")
c:part(c:line({ { 20, 18 }, { 23, 11 }, { 24, 7 } }, 3), "petal")
c:part(c:ellipse(24, 6, 3, 3), "petal")
c:part(c:poly({ { 27, 5 }, { 32, 6 }, { 27, 8 } }), "gold")
c:part(c:poly({ { 11, 19 }, { 9, 11 }, { 16, 15 }, { 19, 20 } }), "ember")
c:eyeSmall(22, 5)
c:px(27, 6, P.ink)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "th-flamingo-flick-perch.aseprite", png = out .. "th-flamingo-flick-perch.png", scale = 1 }
