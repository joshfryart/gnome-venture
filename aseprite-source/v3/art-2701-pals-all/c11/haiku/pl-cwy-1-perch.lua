-- Ember Flake (pl-cwy-1), perch 36x36. Haiku first pass (c11/haiku), hand-drawn at this size.
-- Chunky ember flake with a gold warm core, one crack, hooked knob on top.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local c = HP.canvas{ w = 36, h = 36, scale = 4, name = "pl-cwy-1-perch" }

c:groundShadow(18, 33, 10, 1)
c:part(c:line({ { 16, 7 }, { 16, 4 }, { 19, 3 } }, 2), "ember", { band = 1 })
c:part(c:poly{ { 10, 10 }, { 22, 6 }, { 30, 14 }, { 27, 28 }, { 17, 31 }, { 8, 24 } }, "ember")
c:part(c:ellipse(18, 18, 4, 4), "gold", { band = 1 })
c:fillMask(c:line({ { 12, 11 }, { 15, 14 }, { 14, 20 } }, 1), "#6e2038")
c:eyeSmall(16, 17) c:eyeSmall(20, 17)
c:px(16, 23, "#2b1c26") c:px(18, 23, "#2b1c26")
c:px(32, 8, "#ffe38a") c:px(33, 11, "#ffe38a")

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-cwy-1-perch.aseprite", png = out .. "pl-cwy-1-perch.png", scale = 1 }
