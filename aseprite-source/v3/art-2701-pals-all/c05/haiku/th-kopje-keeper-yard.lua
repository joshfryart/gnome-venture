-- Kopje Keeper (th-kopje-keeper), yard 64x64. Haiku first pass. Uncommon, thornblade.
-- Keeps a stony watch over the savanna and never once blinks.
-- quirk: a little tuft of moss grows on its top, with a sprout beside it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "th-kopje-keeper-yard" }
c:groundShadow(32, 59, 20, 3)
c:part(c:ellipse(32, 38, 20, 16), "stone")
c:part(c:ellipse(25, 27, 9, 7), "stone")
c:part(c:ellipse(42, 30, 6, 5), "stone")
c:part(c:ellipse(40, 21, 4, 2), "moss", { band = 1 })
c:px(39, 19, P.moss.hi) c:px(40, 18, P.moss.hi) c:px(41, 17, P.moss.base)
c:eyeLocked(23, 33) c:eyeLocked(36, 33)
c:px(31, 41, P.stone.deep) c:px(32, 41, P.stone.deep)
c:fillMask(c:line({ { 28, 46 }, { 36, 46 } }, 1), P.ink)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "th-kopje-keeper-yard.aseprite", png = out .. "th-kopje-keeper-yard.png", scale = 1 }
