-- Ash Wreath (pl-cwy-5), perch sprite 36x36. Haiku first pass, hand-drawn at this size.
-- quirk: the unlit ember at the top of the hollow.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-cwy-5-perch" }

c:groundShadow(18, 32, 9, 1)
local ring = c:ellipse(18, 18, 11, 11):cut(c:ellipse(18, 18, 6, 6))
c:part(ring, "stone", { band = 2 })
c:part(c:rect(17, 11, 18, 11), "ember", { band = 1, noshade = true, nopop = true })
c:eyeSmall(15, 16)
c:eyeSmall(20, 16)
c:fillMask(c:rect(17, 21, 18, 21), P.ink)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-cwy-5-perch.aseprite", png = out .. "pl-cwy-5-perch.png", scale = 1 }
