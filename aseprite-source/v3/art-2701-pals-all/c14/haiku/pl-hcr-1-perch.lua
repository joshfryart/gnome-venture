-- Lightning Pinch (pl-hcr-1), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-hcr-1-perch" }
c:part(c:poly{ {2,14},{7,10},{6,15},{10,14},{8,21},{3,21} }, "sky", {})
c:part(c:poly{ {34,14},{29,10},{30,15},{26,14},{28,21},{33,21} }, "sky", {})
c:part(c:ellipse(18, 19, 8, 7), "gold", {})
c:eyeSmall(15, 17)
c:eyeSmall(20, 17)
c:px(18, 22, "#2b1c26")
c:part(c:ellipse(29, 6, 4, 3), "sky", {})
c:sparkle(33, 4)
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-hcr-1-perch.aseprite", png = out .. "pl-hcr-1-perch.png" }
