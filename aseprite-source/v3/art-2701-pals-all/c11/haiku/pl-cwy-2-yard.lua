-- Slag Drip (pl-cwy-2), yard 64x64. Haiku first pass (c11/haiku).
-- Common, seedkeeper, tri knob. "A thick glowing drip that takes its time falling off the forge."
-- quirk: a long glowing drip stretching from the body, the bead at its end about to let go.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local INK = "#2b1c26"
local c = HP.canvas{ w = 64, h = 64, scale = 4, name = "pl-cwy-2-yard" }

c:groundShadow(32, 58, 12, 2)
c:part(c:ellipse(32, 16, 9, 5), "stone", { band = 1 })   -- cold crust clinging to the top
c:part(c:poly{ { 26, 18 }, { 38, 18 }, { 35, 30 }, { 29, 30 } }, "ember")   -- neck
c:part(c:poly{ { 45, 32 }, { 50, 28 }, { 47, 38 } }, "ember", { band = 1 })   -- tri knob
c:part(c:ellipse(32, 38, 14, 12), "ember", { sep = true })
c:part(c:ellipse(32, 40, 6, 5), "gold", { band = 1 })   -- glowing core
c:part(c:poly{ { 30, 49 }, { 34, 49 }, { 33, 54 }, { 31, 54 } }, "ember", { noshade = true })   -- the drip
c:part(c:ellipse(32, 57, 2, 2), "gold", { noshade = true })   -- the bead, not yet let go
c:part(c:poly{ { 40, 24 }, { 45, 22 }, { 43, 27 } }, "stone", { noshade = true, nopop = true })   -- crust chip
c:eyeLocked(24, 36) c:eyeLocked(36, 36)
c:px(31, 44, INK) c:px(32, 44, INK) c:px(30, 45, INK) c:px(33, 45, INK)
c:px(30, 46, INK) c:px(33, 46, INK) c:px(31, 47, INK) c:px(32, 47, INK)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-cwy-2-yard.aseprite", png = out .. "pl-cwy-2-yard.png", scale = 1 }
