-- Grey Wolf Whistle (pl-gwk-6), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-gwk-6-perch" }
c:part(c:poly{ {9,14}, {8,4}, {16,11} }, "stone", { sep = true })
c:part(c:poly{ {22,11}, {27,4}, {27,14} }, "stone", { sep = true })
c:part(c:rect(8, 4, 9, 5), "gold", {})
c:part(c:rect(26, 4, 27, 5), "gold", {})
c:part(c:ellipse(18, 20, 11, 9), "stone", {})
c:part(c:rrect(15, 22, 25, 28, 2), "stone", { sep = true })
c:part(c:rect(24, 25, 25, 26), "dusk", {})
c:eyeSmall(13, 17)
c:eyeSmall(21, 17)
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-gwk-6-perch.aseprite", png = out .. "pl-gwk-6-perch.png" }
