-- Tongue Flicker (pl-dlz-2), yard 64x64. Haiku first pass (c11/haiku).
-- Common, bloomcaller, tri knob. "A forked red tongue that flicks at flies and misses on purpose."
-- quirk: tongue out, forked, aimed at a fly that is one pixel too far away.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../../../lib/hp.lua")
local out = app.params.out or "./"
local INK = "#2b1c26"
local c = HP.canvas{ w = 64, h = 64, scale = 4, name = "pl-dlz-2-yard" }

c:groundShadow(30, 57, 20, 3)
c:part(c:ellipse(20, 51, 4, 4), "wood", { band = 1 })
c:part(c:ellipse(38, 51, 4, 4), "wood", { band = 1 })
c:part(c:poly{ { 16, 36 }, { 21, 26 }, { 28, 35 } }, "gold", { band = 1 })   -- tri knob
c:part(c:ellipse(30, 42, 17, 10), "gold")
c:part(c:ellipse(44, 36, 10, 8), "gold", { sep = true })
c:px(22, 41, "#f5809f") c:px(30, 45, "#f5809f") c:px(14, 44, "#f5809f") c:px(36, 47, "#f5809f")
c:eyeLocked(40, 33)
c:px(47, 42, INK) c:px(48, 42, INK) c:px(49, 43, INK)
-- forked tongue flicking out
local tongue = c:line({ { 52, 38 }, { 58, 38 } }, 1):add(c:line({ { 58, 38 }, { 61, 35 } }, 1)):add(c:line({ { 58, 38 }, { 61, 41 } }, 1))
c:part(tongue, "ember", { noshade = true, nopop = true })
-- the fly it misses
c:part(c:rect(58, 24, 60, 26), "stone", { noshade = true })
c:px(57, 23, "#b9e2f5") c:px(61, 23, "#b9e2f5") c:px(57, 27, "#b9e2f5") c:px(61, 27, "#b9e2f5")

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-dlz-2-yard.aseprite", png = out .. "pl-dlz-2-yard.png", scale = 1 }
