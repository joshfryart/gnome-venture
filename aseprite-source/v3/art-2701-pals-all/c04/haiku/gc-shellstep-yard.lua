-- gc-shellstep-yard (64). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "gc-shellstep-yard"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
c:groundShadow(32, 56, 20, 3)
c:part(c:ellipse(32, 44, 18, 7), "wood")
local shell = c:ellipse(32, 32, 20, 15)
shell:cut(c:rect(0, 36, 63, 63))
c:part(shell, "moss")
c:part(c:ellipse(32, 29, 6, 5), "gold")
c:part(c:ellipse(27, 16, 2, 2), "gold")
c:part(c:ellipse(37, 16, 2, 2), "gold")
c:part(c:ellipse(50, 40, 6, 5), "wood")
c:part(c:ellipse(20, 47, 4, 3), "wood")
c:part(c:ellipse(42, 48, 4, 3), "wood")
c:eyeLocked(48, 38)
c:fillMask(c:rect(4, 40, 8, 40), P.cream)
c:fillMask(c:rect(2, 46, 6, 46), P.cream)
c:fillMask(c:rect(5, 52, 9, 52), P.cream)
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
