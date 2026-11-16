-- dw-oasis-hoop-yard (64). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "dw-oasis-hoop-yard"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
c:part(c:ellipse(32, 53, 26, 5), "sea")
local ring = c:ellipse(32, 34, 20, 18)
ring:cut(c:ellipse(32, 34, 9, 8))
c:part(ring, "gold")
c:part(c:ellipse(24, 15, 3, 3), "gold")
c:part(c:ellipse(40, 15, 3, 3), "gold")
c:part(c:ellipse(27, 30, 2, 3), "wood")
c:part(c:ellipse(36, 31, 2, 3), "wood")
c:eyeLocked(25, 44)
c:eyeLocked(34, 44)
for _, p in ipairs({ {29,49},{30,50},{31,50},{32,50},{33,50},{34,49} }) do c:px(p[1], p[2], P.ink) end
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
