-- Yak Yonder (sp-yak-yonder), perch 36x36. Hand-built at size. Haiku first pass.
-- quirk: the forward-pointing pennant (see yard).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "sp-yak-yonder-perch" }
c:groundShadow(18, 33, 11, 2)
c:part(c:rect(12, 27, 13, 31), "wood", { band = 1 })
c:part(c:rect(21, 27, 22, 31), "wood", { band = 1 })
c:part(c:rect(26, 27, 27, 31), "wood", { band = 1 })
c:part(c:ellipse(20, 20, 11, 7), "wood")
c:part(c:rrect(13, 11, 24, 16, 1), "dusk")
c:part(c:ellipse(7, 20, 4, 4), "wood")
c:part(c:poly({ { 5, 16 }, { 4, 13 }, { 7, 15 } }), "stone")
c:eyeSmall(5, 18) c:eyeSmall(9, 18)
c:px(4, 22, P.ink) c:px(3, 22, P.ink)
c:part(c:line({ { 2, 15 }, { 2, 3 } }, 1), "stone")
c:part(c:poly({ { 2, 3 }, { 9, 5 }, { 2, 7 } }), "ember")
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "sp-yak-yonder-perch.aseprite", png = out .. "sp-yak-yonder-perch.png", scale = 1 }
