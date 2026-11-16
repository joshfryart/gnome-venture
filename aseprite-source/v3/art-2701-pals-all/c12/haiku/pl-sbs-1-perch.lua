-- Silkthread Tuft (pl-sbs-1), perch sprite 36x36. Haiku first pass, hand-drawn at this size.
-- quirk: the dangling sticky strand.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-sbs-1-perch" }
local SILK = { hi = "#fff4ee", base = "#d6cad0", shade = "#a898a8", deep = "#6a5a72" }

c:groundShadow(18, 32, 8, 1)
local tuft = c:ellipse(18, 20, 9, 8):add(c:ellipse(11, 16, 4, 4)):add(c:ellipse(25, 16, 4, 4)):add(c:ellipse(18, 13, 5, 4))
c:part(tuft, SILK, { band = 2 })
c:part(c:line({ {24,26},{26,30},{23,33} }, 1), SILK, { band = 1, noshade = true, nopop = true })
c:eyeSmall(14, 18)
c:eyeSmall(20, 18)
c:cheek(11, 22)
c:cheek(22, 22)
c:fillMask(c:rect(17, 23, 18, 23), P.ink)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-sbs-1-perch.aseprite", png = out .. "pl-sbs-1-perch.png", scale = 1 }
