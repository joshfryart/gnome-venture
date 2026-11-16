-- Ember Flake (pl-cwy-1), yard 64x64. Haiku first pass (c11/haiku).
-- Common, thornblade, hook knob. "A cinder that drifted off the wyrm's back and stayed warm."
-- quirk: a glowing gold core still warm inside the cracked cinder, with sparks drifting off it.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local INK = "#2b1c26"
local c = HP.canvas{ w = 64, h = 64, scale = 4, name = "pl-cwy-1-yard" }

c:groundShadow(32, 58, 16, 2)
c:part(c:line({ { 30, 15 }, { 30, 8 }, { 35, 6 } }, 2), "ember", { band = 1 })   -- hook knob
local flake = c:poly{ { 20, 16 }, { 38, 11 }, { 50, 22 }, { 46, 42 }, { 34, 54 }, { 18, 46 }, { 13, 30 } }
c:part(flake, "ember")
c:part(c:ellipse(32, 32, 7, 6), "gold", { band = 1 })   -- warm core
-- cracks
c:fillMask(c:line({ { 22, 22 }, { 26, 27 }, { 24, 34 } }, 1), "#6e2038")
c:fillMask(c:line({ { 42, 40 }, { 44, 46 }, { 40, 50 } }, 1), "#6e2038")
c:eyeLocked(28, 29) c:eyeLocked(36, 29)
c:px(28, 37, INK) c:px(29, 38, INK) c:px(30, 38, INK) c:px(31, 38, INK) c:px(32, 38, INK) c:px(33, 38, INK) c:px(34, 37, INK)
-- sparks drifting off the core
c:px(10, 14, "#ffe38a") c:px(54, 10, "#ffe38a") c:px(57, 18, "#ffc4d8") c:px(9, 40, "#ffe38a")

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-cwy-1-yard.aseprite", png = out .. "pl-cwy-1-yard.png", scale = 1 }
