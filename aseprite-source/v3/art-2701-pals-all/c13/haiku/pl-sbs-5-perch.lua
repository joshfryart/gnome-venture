-- Dewweb Eye (pl-sbs-5), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-sbs-5-perch" }
c:part(c:ellipse(18, 18, 13, 12), "sky", {})
local ring = c:ellipse(18, 18, 8, 8); ring:cut(c:ellipse(18, 18, 7, 7))
c:part(ring, "stone", {})
for _, p in ipairs({ {7,17}, {25,9}, {26,24} }) do c:part(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "sea", {}) end
c:part(c:ellipse(18, 18, 5, 5), "dusk", {})
c:eyeSmall(15, 17)
c:eyeSmall(20, 17)
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-sbs-5-perch.aseprite", png = out .. "pl-sbs-5-perch.png" }
