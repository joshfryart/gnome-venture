-- Karst Yawn (pl-dlz-5), perch 36x36. Haiku first pass (c11/haiku), hand-drawn at this size.
-- Grey stone chunk, dark mouth open in a yawn, peg knob on top.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local INK = "#2b1c26"
local c = HP.canvas{ w = 36, h = 36, scale = 4, name = "pl-dlz-5-perch" }

c:groundShadow(18, 33, 11, 1)
c:part(c:rect(16, 8, 19, 11), "stone", { band = 1 })   -- peg knob
c:part(c:poly{ { 7, 27 }, { 9, 17 }, { 15, 12 }, { 22, 13 }, { 28, 19 }, { 28, 28 }, { 23, 32 }, { 12, 32 } }, "stone")
c:fillMask(c:ellipse(18, 25, 4, 3), INK)
c:px(15, 22, "#e2e0e6") c:px(21, 22, "#e2e0e6") c:px(18, 28, "#e2e0e6")
c:eyeSmall(11, 18) c:eyeSmall(23, 18)
c:fillMask(c:line({ { 30, 9 }, { 33, 7 } }, 1), "#8bc4ea")

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-dlz-5-perch.aseprite", png = out .. "pl-dlz-5-perch.png", scale = 1 }
