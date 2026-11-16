-- Silverback Spool (pl-sbs-6), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-sbs-6-perch" }
for _, pts in ipairs({ { {10,15},{5,11} }, { {15,14},{11,8} }, { {21,14},{25,8} }, { {26,15},{31,11} },
  { {10,21},{5,25} }, { {15,22},{11,28} }, { {21,22},{25,28} }, { {26,21},{31,25} } }) do
  c:part(c:line(pts, 0), "wood", {})
end
c:part(c:rect(9, 13, 27, 23), "dusk", {})
c:part(c:ellipse(8, 18, 2, 5), "wood", {})
c:part(c:ellipse(28, 18, 2, 5), "wood", {})
c:part(c:rect(9, 15, 27, 15), "sky", { noshade = true })
c:part(c:rect(9, 21, 27, 21), "sky", { noshade = true })
c:part(c:rect(17, 8, 19, 11), "gold", {})
c:eyeSmall(13, 17)
c:eyeSmall(21, 17)
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-sbs-6-perch.aseprite", png = out .. "pl-sbs-6-perch.png" }
