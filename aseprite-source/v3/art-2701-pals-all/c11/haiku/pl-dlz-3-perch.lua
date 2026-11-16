-- Tail Tick (pl-dlz-3), perch 36x36. Haiku first pass (c11/haiku), hand-drawn at this size.
-- Teal round body, double knob, tail up against a pebble with two tick marks.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local INK = "#2b1c26"
local c = HP.canvas{ w = 36, h = 36, scale = 4, name = "pl-dlz-3-perch" }

c:groundShadow(14, 33, 11, 1)
c:part(c:line({ { 18, 30 }, { 25, 30 }, { 28, 25 }, { 28, 17 } }, 3), "sea", { band = 1 })
c:part(c:rect(8, 30, 10, 31), "wood", { band = 1 })
c:part(c:rect(16, 30, 18, 31), "wood", { band = 1 })
c:part(c:rect(9, 16, 10, 17), "sea", { noshade = true })
c:part(c:rect(14, 16, 15, 17), "sea", { noshade = true })
c:part(c:ellipse(13, 24, 8, 7), "sea", { sep = true })
c:eyeSmall(10, 23) c:eyeSmall(16, 23)
c:px(11, 27, INK) c:px(12, 28, INK) c:px(13, 28, INK) c:px(14, 27, INK)
c:part(c:rrect(28, 6, 32, 10, 1), "stone", { band = 1 })
c:fillMask(c:line({ { 30, 13 }, { 33, 11 } }, 1), INK)
c:fillMask(c:line({ { 29, 15 }, { 31, 16 } }, 1), INK)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-dlz-3-perch.aseprite", png = out .. "pl-dlz-3-perch.png", scale = 1 }
