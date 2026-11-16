-- Silkthread Tuft (pl-sbs-1), yard sprite 64x64. Haiku first pass.
-- Common, seedkeeper. "Spun from the spider's worries and still a little bit sticky."
-- A puffy tuft of pale silk with a loose strand trailing off the bottom.
-- quirk: the dangling sticky strand.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-sbs-1-yard" }
local SILK = { hi = "#fff4ee", base = "#d6cad0", shade = "#a898a8", deep = "#6a5a72" }

c:groundShadow(32, 57, 15, 2)
local tuft = c:ellipse(32, 36, 17, 15):add(c:ellipse(21, 30, 8, 8)):add(c:ellipse(43, 30, 8, 8)):add(c:ellipse(32, 24, 9, 7))
c:part(tuft, SILK, { band = 3 })
c:part(c:line({ {28,18},{26,11} }, 1), SILK, { band = 1, noshade = true, nopop = true })
c:part(c:line({ {38,18},{40,11} }, 1), SILK, { band = 1, noshade = true, nopop = true })
c:part(c:line({ {44,44},{47,51},{43,58} }, 1), SILK, { band = 1, noshade = true, nopop = true })   -- sticky strand
c:eyeLocked(25, 33)
c:eyeLocked(36, 33)
c:cheek(21, 40)
c:cheek(40, 40)
c:fillMask(c:rect(30, 43, 33, 43), P.ink)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-sbs-1-yard.aseprite", png = out .. "pl-sbs-1-yard.png", scale = 1 }
