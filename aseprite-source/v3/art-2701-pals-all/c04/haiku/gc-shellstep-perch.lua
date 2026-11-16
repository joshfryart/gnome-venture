-- gc-shellstep-perch (36). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "gc-shellstep-perch"
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = NAME }
c:groundShadow(16, 31, 11, 2)
c:part(c:ellipse(16, 24, 10, 4), "wood")
local shell = c:ellipse(16, 18, 12, 8)
shell:cut(c:rect(0, 22, 35, 35))
c:part(shell, "moss")
c:part(c:ellipse(16, 16, 3, 2), "gold")
c:part(c:ellipse(12, 9, 1, 1), "gold")
c:part(c:ellipse(21, 9, 1, 1), "gold")
c:part(c:ellipse(28, 20, 4, 3), "wood")
c:part(c:ellipse(10, 28, 2, 2), "wood")
c:part(c:ellipse(22, 28, 2, 2), "wood")
c:eyeSmall(27, 19)
c:fillMask(c:rect(1, 19, 4, 19), P.cream)
c:fillMask(c:rect(0, 24, 3, 24), P.cream)
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
