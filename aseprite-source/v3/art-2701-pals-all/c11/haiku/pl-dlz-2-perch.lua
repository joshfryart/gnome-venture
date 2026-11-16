-- Tongue Flicker (pl-dlz-2), perch 36x36. Haiku first pass (c11/haiku), hand-drawn at this size.
-- Low gold lizard, tri knob, forked red tongue out toward a fly it misses.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local c = HP.canvas{ w = 36, h = 36, scale = 4, name = "pl-dlz-2-perch" }

c:groundShadow(16, 32, 12, 1)
c:part(c:rect(8, 28, 10, 31), "wood", { band = 1 })
c:part(c:rect(19, 28, 21, 31), "wood", { band = 1 })
c:part(c:poly{ { 10, 20 }, { 13, 15 }, { 17, 21 } }, "gold", { band = 1 })
c:part(c:ellipse(15, 25, 9, 5), "gold")
c:part(c:ellipse(23, 22, 5, 4), "gold", { sep = true })
c:px(12, 24, "#f5809f") c:px(18, 26, "#f5809f")
c:eyeSmall(22, 20)
c:part(c:line({ { 27, 22 }, { 31, 22 } }, 1), "ember", { noshade = true, nopop = true })
c:px(32, 21, "#e8493b") c:px(32, 23, "#e8493b")
c:px(30, 14, "#b9e2f5") c:px(29, 13, "#b9e2f5") c:px(31, 13, "#b9e2f5")
c:px(30, 15, "#aaa9b8")

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-dlz-2-perch.aseprite", png = out .. "pl-dlz-2-perch.png", scale = 1 }
