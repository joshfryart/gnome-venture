-- Tail Tick (pl-dlz-3), yard 64x64. Haiku first pass (c11/haiku).
-- Common, seedkeeper, double knob. "Ticks its tail against every rock on the path just to hear it."
-- quirk: tail raised mid-tick against a pebble, with tick marks ringing off it.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local INK = "#2b1c26"
local c = HP.canvas{ w = 64, h = 64, scale = 4, name = "pl-dlz-3-yard" }

c:groundShadow(28, 57, 17, 3)
c:part(c:line({ { 34, 50 }, { 44, 52 }, { 52, 46 }, { 53, 36 }, { 49, 27 } }, 5), "sea", { band = 1 })
c:part(c:ellipse(18, 53, 4, 2), "wood", { band = 1 })
c:part(c:ellipse(32, 53, 4, 2), "wood", { band = 1 })
c:part(c:ellipse(25, 28, 3, 3), "sea", { band = 1 })   -- double knob
c:part(c:ellipse(33, 28, 3, 3), "sea", { band = 1 })
c:part(c:ellipse(26, 42, 15, 12), "sea", { sep = true })
c:eyeLocked(18, 38) c:eyeLocked(29, 38)
c:cheek(16, 46) c:cheek(30, 46)
c:px(22, 47, INK) c:px(23, 48, INK) c:px(24, 48, INK) c:px(25, 48, INK) c:px(26, 47, INK)
-- pebble at the tail tip, and the ticks ringing off it
c:part(c:rrect(52, 26, 57, 31, 2), "stone", { band = 1 })
c:fillMask(c:line({ { 45, 24 }, { 48, 21 } }, 1), INK)
c:fillMask(c:line({ { 46, 30 }, { 50, 30 } }, 1), INK)
c:fillMask(c:line({ { 60, 27 }, { 62, 24 } }, 1), INK)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-dlz-3-yard.aseprite", png = out .. "pl-dlz-3-yard.png", scale = 1 }
