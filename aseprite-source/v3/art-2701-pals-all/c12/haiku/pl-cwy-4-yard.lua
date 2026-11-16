-- Spine Spark (pl-cwy-4), yard sprite 64x64. Haiku first pass.
-- Uncommon, thornblade. "Four little spikes that pop like sparklers when stepped on."
-- A round ember ball with four gold spikes and a sparkle on each tip.
-- quirk: the sparkles on the spike tips.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-cwy-4-yard" }

c:groundShadow(32, 57, 13, 2)
local spikes = {
  c:poly({ {24,30},{17,14},{31,25} }),
  c:poly({ {40,30},{47,14},{33,25} }),
  c:poly({ {19,38},{6,31},{20,44} }),
  c:poly({ {45,38},{58,31},{44,44} }),
}
for _, s in ipairs(spikes) do c:part(s, "gold", { band = 1, noshade = true }) end
c:part(c:ellipse(32, 38, 16, 13), "ember", { band = 3 })
c:eyeLocked(25, 36)
c:eyeLocked(35, 36)
c:fillMask(c:rect(31, 43, 33, 43), P.ink)
c:sparkle(17, 12)
c:sparkle(47, 12)
c:sparkle(6, 28)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-cwy-4-yard.aseprite", png = out .. "pl-cwy-4-yard.png", scale = 1 }
