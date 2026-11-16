-- Shell Splinter (pl-hcr-2), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-hcr-2-perch" }
c:part(c:rect(15, 6, 18, 10), "wood", { noshade = true })
c:part(c:poly{ {6,12},{30,12},{33,22},{18,32},{3,22} }, "ember", {})
c:fillMask(c:line({{18,16},{12,30}}, 1), "#6e2038")
c:fillMask(c:line({{18,16},{24,30}}, 1), "#6e2038")
c:eyeSmall(13, 19)
c:eyeSmall(21, 19)
c:paint({ "ii" }, 16, 25, { i = "#2b1c26" })
c:px(1, 14, "#b9e2f5")
c:px(35, 14, "#b9e2f5")
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-hcr-2-perch.aseprite", png = out .. "pl-hcr-2-perch.png" }
