-- gc-parrot-pennant-perch (36). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "gc-parrot-pennant-perch"
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = NAME }
c:groundShadow(16, 32, 6, 1)
c:part(c:ellipse(16, 22, 8, 9), "ember")
c:part(c:ellipse(14, 22, 4, 5), "moss")
c:part(c:poly{ {10,25},{2,27},{3,32},{10,30} }, "sea")
c:part(c:ellipse(19, 11, 6, 5), "ember")
c:part(c:poly{ {24,10},{30,12},{25,14} }, "gold")
c:part(c:line({ {19,6},{19,2},{23,2} }, 1), "gold")
c:eyeSmall(15, 9)
c:eyeSmall(19, 9)
c:sparkle(31, 8)
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
