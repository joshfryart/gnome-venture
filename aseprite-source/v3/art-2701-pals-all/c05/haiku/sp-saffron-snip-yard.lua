-- Saffron Snip (sp-saffron-snip), yard 64x64. Haiku first pass. Common, seedkeeper.
-- Snips saffron threads with tiny scissors and hums while picking.
-- quirk: small music notes drift off to the left while it hums.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "sp-saffron-snip-yard" }
c:groundShadow(30, 60, 17, 3)
c:part(c:ellipse(30, 40, 17, 15), "gold")
c:part(c:line({ { 30, 26 }, { 30, 10 } }, 1), "ember")
c:part(c:line({ { 26, 27 }, { 21, 13 } }, 1), "ember")
c:part(c:line({ { 34, 27 }, { 39, 13 } }, 1), "ember")
c:px(30, 9, P.ember.hi) c:px(21, 12, P.ember.hi) c:px(39, 12, P.ember.hi)
c:part(c:poly({ { 44, 46 }, { 58, 36 }, { 60, 39 }, { 48, 50 } }), "stone")
c:part(c:poly({ { 44, 42 }, { 56, 52 }, { 58, 49 }, { 48, 38 } }), "stone")
c:eyeLocked(20, 38) c:eyeLocked(32, 38)
c:cheek(16, 44) c:cheek(38, 44)
c:px(29, 43, P.gold.deep) c:px(30, 43, P.gold.deep)
c:px(29, 46, P.ink) c:px(30, 46, P.ink) c:px(29, 47, P.ink) c:px(30, 47, P.ink)
c:px(10, 22, P.dusk.base) c:px(10, 23, P.dusk.base) c:px(10, 24, P.dusk.base) c:px(9, 24, P.dusk.base) c:px(8, 23, P.dusk.hi)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "sp-saffron-snip-yard.aseprite", png = out .. "sp-saffron-snip-yard.png", scale = 1 }
