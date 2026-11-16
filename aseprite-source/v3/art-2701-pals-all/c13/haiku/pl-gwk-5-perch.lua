-- Howl Echo (pl-gwk-5), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-gwk-5-perch" }
local r = c:ellipse(18, 20, 15, 15); r:cut(c:ellipse(18, 20, 13, 13)); r:clip(c:rect(20, 0, 35, 14))
c:part(r, "sky", { noshade = true })
c:part(c:rrect(6, 10, 24, 30, 8), "sea", {})
c:eyeSmall(12, 17)
c:eyeSmall(19, 17)
c:part(c:rect(15, 23, 17, 24), "dusk", {})
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-gwk-5-perch.aseprite", png = out .. "pl-gwk-5-perch.png" }
