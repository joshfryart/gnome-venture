-- Mossback Monitor (pl-dlz-6), perch 36x36. Haiku first pass (c11/haiku), hand-drawn at this size. Rare.
-- Moss monitor with gold horns, a gold stitched collar and a curled tail.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local INK = "#2b1c26"
local c = HP.canvas{ w = 36, h = 36, scale = 4, name = "pl-dlz-6-perch" }

c:groundShadow(18, 33, 13, 1)
c:part(c:line({ { 6, 25 }, { 2, 23 }, { 3, 18 }, { 7, 17 } }, 3), "moss", { band = 1 })
c:part(c:rect(11, 29, 13, 31), "moss", { band = 1 })
c:part(c:rect(19, 29, 21, 31), "moss", { band = 1 })
c:part(c:ellipse(16, 24, 10, 6), "moss", { sep = true })
c:part(c:ellipse(25, 20, 6, 5), "moss", { sep = true })
c:part(c:poly{ { 22, 15 }, { 23, 11 }, { 25, 15 } }, "gold", { band = 1 })
c:part(c:poly{ { 26, 15 }, { 28, 11 }, { 29, 15 } }, "gold", { band = 1 })
c:stitch({ { 8, 19 }, { 21, 18 } })
c:eyeSmall(23, 19)
c:px(12, 22, "#c4e07a") c:px(13, 21, "#c4e07a") c:px(14, 21, "#c4e07a")
c:fillMask(c:line({ { 27, 24 }, { 30, 23 } }, 1), INK)
c:sparkle(5, 12)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-dlz-6-perch.aseprite", png = out .. "pl-dlz-6-perch.png", scale = 1 }
