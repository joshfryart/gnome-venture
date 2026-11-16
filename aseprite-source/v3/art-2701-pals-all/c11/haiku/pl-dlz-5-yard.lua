-- Karst Yawn (pl-dlz-5), yard 64x64. Haiku first pass (c11/haiku).
-- Uncommon, rootwarden, peg knob. "A scrap of the dark den mouth that yawns whenever the lizard does."
-- quirk: a stone chunk with the den mouth open wide in a yawn, stalagmite teeth showing.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local INK = "#2b1c26"
local c = HP.canvas{ w = 64, h = 64, scale = 4, name = "pl-dlz-5-yard" }

c:groundShadow(32, 58, 20, 3)
c:part(c:rect(29, 12, 35, 18), "stone", { band = 1 })   -- peg knob
local rock = c:poly{ { 14, 44 }, { 16, 30 }, { 24, 20 }, { 34, 17 }, { 44, 21 }, { 50, 32 }, { 48, 46 }, { 40, 54 }, { 24, 54 }, { 16, 50 } }
c:part(rock, "stone")
-- the den mouth, yawning
c:fillMask(c:ellipse(32, 40, 9, 7), INK)
c:part(c:poly{ { 24, 35 }, { 27, 41 }, { 29, 35 } }, "stone", { noshade = true, nopop = true })   -- upper stalagmites
c:part(c:poly{ { 35, 35 }, { 37, 41 }, { 40, 35 } }, "stone", { noshade = true, nopop = true })
c:part(c:poly{ { 29, 46 }, { 32, 42 }, { 35, 46 } }, "stone", { noshade = true, nopop = true })   -- lower stalagmite
c:eyeLocked(20, 27) c:eyeLocked(38, 27)
-- yawn wisps
c:fillMask(c:line({ { 46, 14 }, { 52, 10 } }, 1), "#8bc4ea")
c:fillMask(c:line({ { 50, 18 }, { 56, 15 } }, 1), "#8bc4ea")

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-dlz-5-yard.aseprite", png = out .. "pl-dlz-5-yard.png", scale = 1 }
