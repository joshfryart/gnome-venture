-- Last Forge Flame (pl-cwy-6), perch sprite 36x36. Haiku first pass, hand-drawn at this size.
-- Rare. quirk: the tiny dragon in the thought bubble.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-cwy-6-perch" }

c:groundShadow(16, 32, 9, 1)
c:part(c:ellipse(16, 29, 9, 3), "ember", { band = 1, noshade = true, nopop = true })
c:part(c:poly({ {18,1},{23,9},{26,16},{25,24},{21,28},{15,28},{11,24},{10,16},{13,9} }), "ember", { band = 2 })
c:part(c:poly({ {18,8},{21,14},{22,20},{19,24},{16,20},{15,14} }), "gold", { band = 1, noshade = true, nopop = true })
c:eyeSmall(14, 17)
c:eyeSmall(20, 17)
c:fillMask(c:rect(17, 22, 18, 22), P.ink)
c:part(c:poly({ {25,10},{23,12},{26,11} }), "sky", { band = 1, noshade = true, nopop = true })
c:part(c:ellipse(31, 6, 4, 3), "sky", { band = 1, noshade = true, nopop = true })
c:part(c:poly({ {28,5},{31,4},{34,5},{33,6},{30,6} }), "dusk", { band = 1, noshade = true, nopop = true })
c:sparkle(32, 22)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-cwy-6-perch.aseprite", png = out .. "pl-cwy-6-perch.png", scale = 1 }
