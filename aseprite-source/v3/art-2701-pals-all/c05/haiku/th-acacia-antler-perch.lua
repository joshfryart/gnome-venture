-- Acacia Antler (th-acacia-antler), perch 36x36. Hand-built at size. Haiku first pass.
-- quirk: gold weaver nests at the twig tips (see yard).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "th-acacia-antler-perch" }
c:groundShadow(18, 33, 8, 2)
c:part(c:rect(13, 27, 14, 31), "wood", { band = 1 })
c:part(c:rect(21, 27, 22, 31), "wood", { band = 1 })
c:part(c:line({ { 14, 16 }, { 10, 8 }, { 7, 4 } }, 2), "wood")
c:part(c:line({ { 22, 16 }, { 26, 8 }, { 29, 4 } }, 2), "wood")
c:part(c:ellipse(6, 6, 2, 1), "gold")
c:part(c:ellipse(29, 6, 2, 1), "gold")
c:part(c:ellipse(18, 22, 8, 7), "moss")
c:eyeSmall(14, 20) c:eyeSmall(20, 20)
c:px(17, 24, P.moss.deep) c:px(18, 24, P.moss.deep)
c:px(15, 26, P.ink) c:px(16, 27, P.ink) c:px(17, 27, P.ink) c:px(18, 27, P.ink)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "th-acacia-antler-perch.aseprite", png = out .. "th-acacia-antler-perch.png", scale = 1 }
