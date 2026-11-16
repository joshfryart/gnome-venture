-- Shell Splinter (pl-hcr-2), yard 64x64. Haiku first pass.
-- Rootwarden, common. A bit of orange shell that rattles in the wind.
-- quirk: little wind ticks on both sides.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-hcr-2-yard" }
c:groundShadow(32, 59, 13, 3)
c:part(c:rect(30, 23, 33, 30), "wood", { noshade = true })
c:part(c:poly{ {14,30},{50,30},{56,44},{44,57},{32,60},{20,57},{8,44} }, "ember", {})
c:fillMask(c:line({{20,36},{24,54}}, 1), "#6e2038")
c:fillMask(c:line({{44,36},{40,54}}, 1), "#6e2038")
c:eyeLocked(23, 37)
c:eyeLocked(36, 37)
c:paint({ "iii" }, 30, 46, { i = "#2b1c26" })
c:px(2, 30, "#b9e2f5")
c:px(4, 24, "#b9e2f5")
c:px(60, 30, "#b9e2f5")
c:px(58, 24, "#b9e2f5")
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-hcr-2-yard.aseprite", png = out .. "pl-hcr-2-yard.png" }
