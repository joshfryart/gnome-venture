-- Eye of the Storm (pl-hcr-5), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-hcr-5-perch" }
local ring = c:ellipse(18, 18, 13, 12)
ring:cut(c:ellipse(18, 18, 5, 5))
c:part(ring, "stone", {})
c:part(c:ellipse(18, 18, 5, 5), "sky", { noshade = true })
c:fillMask(c:line({{3,12},{6,9}}, 1), "#444663")
c:fillMask(c:line({{30,26},{33,28}}, 1), "#444663")
c:part(c:poly{ {29,4},{33,2},{34,6},{30,8} }, "moss", {})
c:eyeSmall(16, 16)
c:eyeSmall(19, 16)
c:px(17, 20, "#2b1c26")
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-hcr-5-perch.aseprite", png = out .. "pl-hcr-5-perch.png" }
