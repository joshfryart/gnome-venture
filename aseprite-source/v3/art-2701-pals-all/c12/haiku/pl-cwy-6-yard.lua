-- Last Forge Flame (pl-cwy-6), yard sprite 64x64. Haiku first pass.
-- Rare, wayfinder. "The wyrm's last little flame from the forge, curled up and dreaming of dragons."
-- A small flame curled on a coil of ember, asleep, with a thought bubble holding a tiny dragon.
-- quirk: the dragon in the thought bubble. Rare: sparkles and a bubble trail.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-cwy-6-yard" }

c:groundShadow(32, 58, 15, 2)
c:part(c:ellipse(32, 52, 14, 5), "ember", { band = 1, noshade = true })          -- coiled on the forge floor
c:part(c:poly({ {32,4},{40,18},{45,31},{43,43},{35,50},{27,50},{20,43},{19,31},{24,18} }), "ember", { band = 3 })
c:part(c:poly({ {32,14},{37,24},{38,34},{34,42},{30,42},{26,34},{27,24} }), "gold", { band = 2 })
c:eyeLocked(26, 30)
c:eyeLocked(35, 30)
c:cheek(23, 37)
c:cheek(38, 37)
c:fillMask(c:rect(30, 40, 33, 40), P.ink)
-- thought bubble with a tiny dragon
c:part(c:poly({ {45,17},{42,22},{48,19} }), "sky", { band = 1, noshade = true, nopop = true })
c:part(c:ellipse(53, 11, 8, 6), "sky", { band = 2 })
c:part(c:poly({ {47,12},{50,8},{55,9},{58,7},{56,11},{52,12},{49,14} }), "dusk", { band = 1, noshade = true, nopop = true })
c:sparkle(10, 18)
c:sparkle(59, 30)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-cwy-6-yard.aseprite", png = out .. "pl-cwy-6-yard.png", scale = 1 }
