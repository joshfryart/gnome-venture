-- gc-canopy-loop-yard (64). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "gc-canopy-loop-yard"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
c:groundShadow(30, 58, 16, 3)
c:part(c:ellipse(28, 34, 16, 17), "moss")
c:part(c:ellipse(28, 13, 3, 3), "gold")
c:px(28, 13, P.ink)
local loop = c:ellipse(48, 47, 7, 7)
loop:cut(c:ellipse(48, 47, 3, 3))
c:part(loop, "moss")
c:part(c:ellipse(49, 14, 3, 3), "petal")
c:px(49, 14, P.gold.base)
c:eyeLocked(22, 30)
c:eyeLocked(31, 30)
for _, p in ipairs({ {23,37},{24,38},{25,38},{26,38},{27,38},{28,38},{29,37} }) do c:px(p[1], p[2], P.ink) end
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
