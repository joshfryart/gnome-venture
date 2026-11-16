-- Wing Jot (pl-jdf-1), yard 64x64. Haiku first pass.
-- Thornblade, common. A jade flake that falls off a wing and hums as it drifts.
-- quirk: hum ticks off the right side, and a falling sparkle below.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-jdf-1-yard" }
local flake = c:poly{ {14,12},{36,6},{52,20},{48,44},{30,58},{12,44},{6,26} }
c:part(flake, "sea", {})
c:fillMask(c:line({{14,12},{30,30},{48,44}}, 1), "#2a4a7a")
c:fillMask(c:line({{30,30},{30,58}}, 1), "#2a4a7a")
c:fillMask(c:line({{36,6},{30,30},{6,26}}, 1), "#2a4a7a")
c:eyeLocked(22, 25)
c:eyeLocked(34, 25)
c:paint({ ".ii.", "i..i", ".ii." }, 28, 35, { i = "#2b1c26" })
c:fillMask(c:line({{56,34},{60,30},{56,26},{60,22}}, 1), "#5f9ad0")
c:sparkle(56, 50)
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-jdf-1-yard.aseprite", png = out .. "pl-jdf-1-yard.png" }
