-- gc-yam-nub-perch (36). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "gc-yam-nub-perch"
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = NAME }
c:groundShadow(18, 32, 9, 2)
local body = c:ellipse(18, 21, 9, 8)
body:add(c:ellipse(11, 26, 3, 3))
body:add(c:ellipse(25, 26, 3, 3))
c:part(body, "wood")
c:part(c:rect(16, 12, 19, 14), "wood")
c:part(c:ellipse(14, 10, 2, 1), "moss")
c:part(c:ellipse(21, 10, 2, 1), "moss")
c:eyeSmall(14, 18)
c:eyeSmall(21, 18)
c:fillMask(c:ellipse(18, 23, 2, 1), P.ink)
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
