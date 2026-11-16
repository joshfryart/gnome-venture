-- gc-calabash-cup-perch (36). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "gc-calabash-cup-perch"
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = NAME }
c:groundShadow(16, 33, 9, 2)
local body = c:ellipse(16, 22, 9, 8)
body:add(c:ellipse(16, 12, 4, 4))
c:part(body, "gold")
c:part(c:ellipse(16, 6, 2, 2), "gold")
c:part(c:ellipse(28, 30, 1, 2), "sea")
c:eyeSmall(12, 19)
c:eyeSmall(18, 19)
for _, p in ipairs({ {14,23},{15,24},{16,24},{17,23} }) do c:px(p[1], p[2], P.ink) end
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
