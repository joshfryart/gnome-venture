-- gc-canopy-loop-perch (36). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "gc-canopy-loop-perch"
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = NAME }
c:groundShadow(14, 30, 9, 2)
c:part(c:ellipse(14, 17, 8, 9), "moss")
c:part(c:ellipse(14, 6, 2, 2), "gold")
c:px(14, 6, P.ink)
local loop = c:ellipse(26, 25, 4, 4)
loop:cut(c:ellipse(26, 25, 2, 2))
c:part(loop, "moss")
c:part(c:ellipse(27, 9, 2, 2), "petal")
c:px(27, 9, P.gold.base)
c:eyeSmall(11, 16)
c:eyeSmall(16, 16)
for _, p in ipairs({ {12,21},{13,22},{14,22},{15,22} }) do c:px(p[1], p[2], P.ink) end
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
