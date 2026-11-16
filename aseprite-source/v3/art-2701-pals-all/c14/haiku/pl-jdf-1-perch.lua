-- Wing Jot (pl-jdf-1), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-jdf-1-perch" }
local flake = c:poly{ {7,6},{22,3},{31,12},{27,27},{15,32},{5,20} }
c:part(flake, "sea", {})
c:fillMask(c:line({{7,6},{18,16},{27,27}}, 1), "#2a4a7a")
c:fillMask(c:line({{22,3},{18,16},{5,20}}, 1), "#2a4a7a")
c:eyeSmall(13, 13)
c:eyeSmall(20, 13)
c:px(16, 21, "#2b1c26")
c:px(17, 21, "#2b1c26")
c:px(33, 20, "#b9e2f5")
c:px(35, 16, "#b9e2f5")
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-jdf-1-perch.aseprite", png = out .. "pl-jdf-1-perch.png" }
