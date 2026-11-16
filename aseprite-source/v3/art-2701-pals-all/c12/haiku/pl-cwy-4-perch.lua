-- Spine Spark (pl-cwy-4), perch sprite 36x36. Haiku first pass, hand-drawn at this size.
-- quirk: a sparkle on the top spike tips.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-cwy-4-perch" }

c:groundShadow(18, 32, 8, 1)
local spikes = {
  c:poly({ {12,13},{8,5},{15,11} }),
  c:poly({ {24,13},{28,5},{21,11} }),
  c:poly({ {10,20},{3,17},{10,24} }),
  c:poly({ {26,20},{33,17},{26,24} }),
}
for _, s in ipairs(spikes) do c:part(s, "gold", { band = 1, noshade = true, nopop = true }) end
c:part(c:ellipse(18, 19, 9, 8), "ember", { band = 2 })
c:eyeSmall(14, 17)
c:eyeSmall(20, 17)
c:fillMask(c:rect(17, 22, 18, 22), P.ink)
c:sparkle(8, 3)
c:sparkle(28, 3)

c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "pl-cwy-4-perch.aseprite", png = out .. "pl-cwy-4-perch.png", scale = 1 }
