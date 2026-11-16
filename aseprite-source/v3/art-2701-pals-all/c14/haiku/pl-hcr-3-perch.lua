-- Gust Ribbon (pl-hcr-3), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-hcr-3-perch" }
local ring = c:ellipse(18, 17, 11, 10)
ring:cut(c:ellipse(18, 17, 6, 5))
c:part(ring, "moss", {})
c:part(c:poly{ {6,24},{10,22},{12,30},{8,33},{4,29} }, "moss", {})
c:eyeSmall(15, 15)
c:eyeSmall(20, 15)
c:px(17, 21, "#2b1c26")
c:px(18, 21, "#2b1c26")
c:px(29, 5, "#b9e2f5")
c:px(3, 8, "#b9e2f5")
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-hcr-3-perch.aseprite", png = out .. "pl-hcr-3-perch.png" }
