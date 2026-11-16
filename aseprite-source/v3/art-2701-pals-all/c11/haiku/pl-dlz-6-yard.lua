-- Mossback Monitor (pl-dlz-6), yard 64x64. Haiku first pass (c11/haiku). Rare, so a touch fancier.
-- Rare, thornblade, whimsy-lizard shape, double knob. "A pocket-sized monitor lizard, polished by a hundred jungle naps."
-- quirk: polish shine on the back, a gold collar of stitches, and a moss tuft on its spine.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local INK = "#2b1c26"
local c = HP.canvas{ w = 64, h = 64, scale = 4, name = "pl-dlz-6-yard" }

c:groundShadow(30, 58, 22, 3)
c:part(c:line({ { 14, 44 }, { 6, 42 }, { 4, 36 }, { 8, 30 }, { 14, 30 } }, 5), "moss", { band = 1 })   -- curled tail
c:part(c:ellipse(22, 52, 4, 3), "moss", { band = 1 })
c:part(c:ellipse(40, 52, 4, 3), "moss", { band = 1 })
c:part(c:ellipse(30, 40, 17, 11), "moss", { sep = true })
c:part(c:ellipse(44, 33, 10, 8), "moss", { sep = true })
c:part(c:poly{ { 40, 27 }, { 42, 21 }, { 44, 26 } }, "gold", { band = 1 })   -- double knob horns
c:part(c:poly{ { 46, 26 }, { 49, 20 }, { 51, 25 } }, "gold", { band = 1 })
c:part(c:poly{ { 28, 29 }, { 30, 22 }, { 33, 28 } }, "moss", { band = 1 })   -- spine tuft
-- gold collar of stitches along the back
c:stitch({ { 12, 40 }, { 30, 30 }, { 42, 26 } })
-- polish shine along the flank
for i = 0, 9 do c:px(18 + i, 45 - (i // 3), "#c4e07a") end
c:eyeLocked(42, 30)
c:cheek(36, 38)
c:fillMask(c:line({ { 48, 38 }, { 53, 38 } }, 1), INK)
c:sparkle(12, 22) c:sparkle(56, 28)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-dlz-6-yard.aseprite", png = out .. "pl-dlz-6-yard.png", scale = 1 }
