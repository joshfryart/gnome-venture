-- Gale Islander (pl-hcr-6), yard 64x64. Haiku first pass.
-- Wayfinder, rare. A pocket crab with a whole tiny island on its back.
-- quirk: two palm trees on the island, sparkles on the sea breeze.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-hcr-6-yard" }
c:groundShadow(32, 60, 18, 3)
for _, l in ipairs({ {{18,48},{10,54}}, {{22,52},{16,58}}, {{46,48},{54,54}}, {{42,52},{48,58}} }) do
  c:part(c:line(l, 2), "ember", { noshade = true })
end
c:part(c:ellipse(8, 38, 5, 4), "ember", {})
c:part(c:ellipse(56, 38, 5, 4), "ember", {})
c:part(c:ellipse(32, 42, 18, 10), "ember", {})
c:eyeLocked(24, 40)
c:eyeLocked(35, 40)
c:paint({ "iii" }, 30, 47, { i = "#2b1c26" })
c:part(c:ellipse(32, 32, 13, 4), "gold", {})
c:part(c:ellipse(32, 28, 11, 3), "moss", { noshade = true })
c:fillMask(c:line({{24,27},{21,15}}, 1), "#51302b")
c:fillMask(c:line({{40,27},{43,14}}, 1), "#51302b")
c:part(c:ellipse(19, 13, 4, 2), "moss", {})
c:part(c:ellipse(45, 11, 4, 2), "moss", {})
c:sparkle(52, 18)
c:sparkle(12, 22)
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-hcr-6-yard.aseprite", png = out .. "pl-hcr-6-yard.png" }
