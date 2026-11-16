-- dw-oasis-hoop-perch (36). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "dw-oasis-hoop-perch"
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = NAME }
c:part(c:ellipse(18, 29, 14, 3), "sea")
local ring = c:ellipse(18, 18, 11, 10)
ring:cut(c:ellipse(18, 18, 5, 4))
c:part(ring, "gold")
c:part(c:ellipse(13, 6, 2, 2), "gold")
c:part(c:ellipse(23, 6, 2, 2), "gold")
c:part(c:ellipse(16, 17, 1, 2), "wood")
c:part(c:ellipse(20, 17, 1, 2), "wood")
c:eyeSmall(14, 23)
c:eyeSmall(20, 23)
for _, p in ipairs({ {16,26},{17,26},{18,26},{19,26} }) do c:px(p[1], p[2], P.ink) end
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
