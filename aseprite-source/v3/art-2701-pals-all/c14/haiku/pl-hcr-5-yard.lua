-- Eye of the Storm (pl-hcr-5), yard 64x64. Haiku first pass.
-- Bloomcaller, uncommon. A calm round hole in the middle of a very loud wind.
-- quirk: a single moss leaf sitting above the storm, and wind streaks.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-hcr-5-yard" }
c:groundShadow(32, 60, 18, 3)
local ring = c:ellipse(32, 31, 24, 22)
ring:cut(c:ellipse(32, 31, 10, 9))
c:part(ring, "stone", {})
c:part(c:ellipse(32, 31, 10, 9), "sky", { noshade = true })
c:fillMask(c:line({{46,10},{54,12}}, 1), "#444663")
c:fillMask(c:line({{6,44},{12,48}}, 1), "#444663")
c:fillMask(c:line({{8,20},{12,14}}, 1), "#444663")
c:eyeLocked(25, 28)
c:eyeLocked(34, 28)
c:paint({ "ii" }, 30, 35, { i = "#2b1c26" })
c:part(c:poly{ {50,6},{56,2},{60,8},{54,12} }, "moss", {})
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-hcr-5-yard.aseprite", png = out .. "pl-hcr-5-yard.png" }
