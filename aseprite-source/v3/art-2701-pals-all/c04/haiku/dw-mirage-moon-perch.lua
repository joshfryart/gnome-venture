-- dw-mirage-moon-perch (36). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "dw-mirage-moon-perch"
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = NAME }
local moon = c:ellipse(17, 19, 10, 10)
moon:cut(c:ellipse(22, 16, 8, 8))
c:part(moon, "dusk")
c:part(c:ellipse(10, 4, 2, 2), "gold")
c:px(10, 4, P.ink)
c:eyeSmall(9, 17)
c:eyeSmall(12, 17)
for _, p in ipairs({ {10,23},{11,23},{12,23} }) do c:px(p[1], p[2], P.ink) end
c:sparkle(30, 6)
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
