-- Slag Drip (pl-cwy-2), perch 36x36. Haiku first pass (c11/haiku), hand-drawn at this size.
-- Ember blob with a stone crust on top, a neck and a small drip hanging from its base.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local c = HP.canvas{ w = 36, h = 36, scale = 4, name = "pl-cwy-2-perch" }

c:groundShadow(18, 33, 8, 1)
c:part(c:ellipse(18, 8, 6, 3), "stone", { band = 1 })
c:part(c:poly{ { 14, 10 }, { 22, 10 }, { 20, 17 }, { 16, 17 } }, "ember")
c:part(c:poly{ { 26, 20 }, { 30, 17 }, { 28, 24 } }, "ember", { band = 1 })   -- tri knob
c:part(c:ellipse(18, 22, 9, 7), "ember", { sep = true })
c:part(c:ellipse(18, 24, 3, 3), "gold", { band = 1 })
c:part(c:poly{ { 16, 28 }, { 19, 28 }, { 18, 31 }, { 17, 31 } }, "ember", { noshade = true })   -- drip
c:px(17, 33, "#e8493b") c:px(17, 34, "#ffe38a")
c:eyeSmall(14, 20) c:eyeSmall(20, 20)
c:px(16, 25, "#2b1c26") c:px(19, 25, "#2b1c26")

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-cwy-2-perch.aseprite", png = out .. "pl-cwy-2-perch.png", scale = 1 }
