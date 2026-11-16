-- Saffron Snip (sp-saffron-snip), perch 36x36. Hand-built at size. Haiku first pass.
-- quirk: the saffron crown and scissors (see yard).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "sp-saffron-snip-perch" }
c:groundShadow(16, 33, 10, 2)
c:part(c:ellipse(16, 21, 10, 9), "gold")
c:part(c:line({ { 16, 13 }, { 16, 3 } }, 1), "ember")
c:part(c:line({ { 13, 14 }, { 10, 5 } }, 1), "ember")
c:part(c:line({ { 19, 14 }, { 22, 5 } }, 1), "ember")
c:part(c:poly({ { 25, 24 }, { 32, 17 }, { 33, 19 }, { 27, 26 } }), "stone")
c:part(c:poly({ { 25, 21 }, { 31, 27 }, { 29, 29 }, { 24, 24 } }), "stone")
c:eyeSmall(12, 19) c:eyeSmall(19, 19)
c:px(15, 23, P.gold.deep) c:px(16, 23, P.gold.deep)
c:px(14, 25, P.ink) c:px(15, 26, P.ink) c:px(16, 26, P.ink)
c:px(31, 6, P.dusk.base) c:px(31, 7, P.dusk.base) c:px(30, 8, P.dusk.hi)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "sp-saffron-snip-perch.aseprite", png = out .. "sp-saffron-snip-perch.png", scale = 1 }
