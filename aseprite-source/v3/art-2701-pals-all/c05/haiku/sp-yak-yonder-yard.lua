-- Yak Yonder (sp-yak-yonder), yard 64x64. Haiku first pass. Common, wayfinder.
-- Leads a laden yak across the bridge, because yonder is always further.
-- quirk: a small pennant on a stick points forward, always ahead.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sp-yak-yonder-yard" }
c:groundShadow(34, 60, 22, 3)
c:part(c:rect(18, 50, 21, 58), "wood", { band = 1 })
c:part(c:rect(29, 50, 32, 58), "wood", { band = 1 })
c:part(c:rect(42, 50, 45, 58), "wood", { band = 1 })
c:part(c:line({ { 52, 38 }, { 57, 46 } }, 2), "wood")
c:part(c:ellipse(34, 40, 19, 11), "wood")
c:part(c:rrect(24, 25, 40, 33, 2), "dusk")
c:stitch({ { 24, 29 }, { 40, 29 } })
c:px(22, 50, P.wood.deep) c:px(28, 51, P.wood.deep) c:px(36, 51, P.wood.deep) c:px(44, 51, P.wood.deep) c:px(50, 47, P.wood.deep)
c:part(c:ellipse(12, 38, 8, 7), "wood")
c:part(c:poly({ { 9, 31 }, { 6, 25 }, { 11, 29 } }), "stone")
c:part(c:poly({ { 14, 31 }, { 16, 25 }, { 17, 30 } }), "stone")
c:eyeLocked(8, 35) c:eyeLocked(14, 35)
c:part(c:ellipse(7, 43, 3, 2), "stone")
c:px(5, 43, P.ink)
c:part(c:line({ { 7, 30 }, { 5, 6 } }, 1), "stone")
c:part(c:poly({ { 5, 6 }, { 16, 9 }, { 5, 13 } }), "ember")
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "sp-yak-yonder-yard.aseprite", png = out .. "sp-yak-yonder-yard.png", scale = 1 }
