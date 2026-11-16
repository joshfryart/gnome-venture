-- Moonpale Mantle (pl-gwk-3), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-gwk-3-perch" }
c:part(c:poly{ {7,6}, {29,6}, {30,24}, {25,31}, {18,27}, {11,31}, {6,24} }, "dusk", {})
c:part(c:ellipse(18, 22, 3, 3), "sky", {})
c:eyeSmall(13, 12)
c:eyeSmall(20, 12)
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-gwk-3-perch.aseprite", png = out .. "pl-gwk-3-perch.png" }
