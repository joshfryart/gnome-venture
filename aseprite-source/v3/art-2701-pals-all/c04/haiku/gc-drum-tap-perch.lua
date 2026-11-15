-- gc-drum-tap-perch (36). Haiku first pass; hand-placed, not a downscale.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local NAME = "gc-drum-tap-perch"
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = NAME }
c:part(c:rect(8, 15, 27, 27), "ember")
c:part(c:rect(8, 26, 27, 27), "gold")
c:part(c:ellipse(18, 15, 10, 3), "sky")
c:part(c:ellipse(10, 12, 1, 1), "gold")
c:part(c:ellipse(26, 12, 1, 1), "gold")
c:part(c:ellipse(3, 6, 1, 1), "sea")
c:part(c:ellipse(32, 4, 1, 1), "sea")
c:eyeSmall(12, 20)
c:eyeSmall(21, 20)
for _, p in ipairs({ {14,24},{15,25},{16,25},{17,25},{18,25},{19,25},{20,24} }) do c:px(p[1], p[2], P.ink) end
c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
