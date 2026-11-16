-- Scorch Sliver (pl-cwy-3), perch sprite 36x36. Haiku first pass, hand-drawn at this size.
-- quirk: the smoke curl off the tip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-cwy-3-perch" }

c:groundShadow(18, 33, 7, 1)
c:part(c:poly({ {19,3},{23,14},{22,25},{20,30},{16,30},{13,25},{12,15} }), "ember", { band = 2 })
c:fillMask(c:line({ {17,8},{19,15},{16,22} }, 1), "#6e2038")
c:part(c:line({ {19,3},{21,0} }, 1), "stone", { band = 1, noshade = true, nopop = true })
c:eyeSmall(15, 16)
c:eyeSmall(20, 16)
c:fillMask(c:rect(17, 22, 18, 22), P.ink)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-cwy-3-perch.aseprite", png = out .. "pl-cwy-3-perch.png", scale = 1 }
