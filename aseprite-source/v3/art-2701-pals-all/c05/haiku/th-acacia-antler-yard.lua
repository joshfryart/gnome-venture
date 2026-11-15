-- Acacia Antler (th-acacia-antler), yard 64x64. Haiku first pass. Uncommon, rootwarden.
-- Grows antler-like twigs and hangs weaver nests from every one.
-- quirk: a gold weaver nest hangs from each twig tip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "th-acacia-antler-yard" }
c:groundShadow(32, 59, 14, 3)
c:part(c:rect(24, 52, 27, 58), "wood", { band = 1 })
c:part(c:rect(36, 52, 39, 58), "wood", { band = 1 })
c:part(c:line({ { 28, 34 }, { 22, 20 }, { 16, 11 } }, 3), "wood")
c:part(c:line({ { 36, 34 }, { 42, 20 }, { 48, 10 } }, 3), "wood")
c:part(c:line({ { 22, 20 }, { 30, 14 } }, 2), "wood")
c:part(c:line({ { 42, 20 }, { 36, 12 } }, 2), "wood")
c:part(c:ellipse(16, 14, 3, 2), "gold")
c:part(c:ellipse(48, 13, 3, 2), "gold")
c:part(c:ellipse(30, 16, 3, 2), "gold")
c:part(c:ellipse(32, 42, 14, 12), "moss")
c:eyeLocked(25, 38) c:eyeLocked(36, 38)
c:cheek(22, 45) c:cheek(40, 45)
c:px(31, 44, P.moss.deep) c:px(32, 44, P.moss.deep)
c:px(28, 49, P.ink) c:px(29, 50, P.ink) c:px(30, 50, P.ink) c:px(31, 50, P.ink) c:px(32, 50, P.ink) c:px(33, 49, P.ink)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "th-acacia-antler-yard.aseprite", png = out .. "th-acacia-antler-yard.png", scale = 1 }
