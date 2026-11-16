-- Buttress Tangle (pl-sbs-3), perch sprite 36x36. Haiku first pass, hand-drawn at this size.
-- quirk: the dark hollow under the knot.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-sbs-3-perch" }

c:part(c:poly({ {2,33},{6,25},{12,28},{13,33} }), "wood", { band = 1 })
c:part(c:poly({ {34,33},{30,25},{24,28},{23,33} }), "wood", { band = 1 })
c:fillMask(c:ellipse(18, 31, 4, 2), P.wood.deep)
c:part(c:ellipse(18, 15, 9, 8), "gold", { band = 2 })
c:fillMask(c:line({ {10,18},{18,22},{27,17} }, 1), P.gold.deep)
c:eyeSmall(14, 13)
c:eyeSmall(20, 13)
c:fillMask(c:rect(17, 18, 18, 18), P.ink)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-sbs-3-perch.aseprite", png = out .. "pl-sbs-3-perch.png", scale = 1 }
