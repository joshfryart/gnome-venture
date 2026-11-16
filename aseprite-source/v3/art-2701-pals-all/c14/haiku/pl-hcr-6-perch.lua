-- Gale Islander (pl-hcr-6), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-hcr-6-perch" }
c:groundShadow(18, 33, 11, 2)
c:part(c:ellipse(18, 24, 11, 6), "ember", {})
c:part(c:ellipse(4, 24, 3, 2), "ember", {})
c:part(c:ellipse(32, 24, 3, 2), "ember", {})
c:part(c:ellipse(18, 19, 8, 3), "gold", {})
c:part(c:ellipse(18, 17, 7, 1), "moss", { noshade = true })
c:fillMask(c:line({{14,17},{11,10}}, 1), "#51302b")
c:fillMask(c:line({{22,17},{25,9}}, 1), "#51302b")
c:part(c:ellipse(9, 8, 3, 1), "moss", {})
c:part(c:ellipse(26, 8, 3, 1), "moss", {})
c:eyeSmall(14, 25)
c:eyeSmall(21, 25)
c:px(18, 29, "#2b1c26")
c:sparkle(30, 4)
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-hcr-6-perch.aseprite", png = out .. "pl-hcr-6-perch.png" }
