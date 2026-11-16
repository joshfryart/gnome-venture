-- Diamond Spur (pl-dlz-4), yard 64x64. Haiku first pass (c11/haiku).
-- Uncommon, thornblade, hook knob. "Four diamond bumps off the lizard's back, very proud of their pattern."
-- quirk: four gold diamonds on the back, one catching the light, and a smug little mouth.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local INK = "#2b1c26"
local c = HP.canvas{ w = 64, h = 64, scale = 4, name = "pl-dlz-4-yard" }

local function dia(cx, cy) return c:poly{ { cx, cy - 4 }, { cx + 3, cy }, { cx, cy + 4 }, { cx - 3, cy } } end

c:groundShadow(32, 57, 18, 3)
c:part(c:line({ { 46, 44 }, { 54, 44 }, { 57, 40 } }, 3), "wood", { band = 1 })   -- hook tail
c:part(c:ellipse(22, 52, 4, 3), "wood", { band = 1 })
c:part(c:ellipse(42, 52, 4, 3), "wood", { band = 1 })
c:part(c:ellipse(32, 40, 17, 13), "wood")
c:part(dia(20, 30), "gold", { noshade = true, nopop = true })
c:part(dia(29, 26), "gold", { noshade = true, nopop = true })
c:part(dia(38, 26), "gold", { noshade = true, nopop = true })
c:part(dia(47, 31), "gold", { noshade = true, nopop = true })
c:eyeLocked(24, 40) c:eyeLocked(37, 40)
c:cheek(20, 46) c:cheek(40, 46)
-- smug little mouth, one corner up
c:fillMask(c:line({ { 28, 49 }, { 36, 49 } }, 1), INK)
c:px(37, 48, INK)
c:sparkle(44, 22)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-dlz-4-yard.aseprite", png = out .. "pl-dlz-4-yard.png", scale = 1 }
