-- Gust Ribbon (pl-hcr-3), yard 64x64. Haiku first pass.
-- Seedkeeper, common. A leaf ribbon that flutters in a little circle.
-- quirk: a loop of leaf ribbon with a gap, and wind sparks around it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-hcr-3-yard" }
c:groundShadow(32, 59, 14, 3)
local ring = c:ellipse(32, 30, 22, 20)
ring:cut(c:ellipse(32, 30, 11, 10))
ring:cut(c:rect(44, 36, 56, 48))
c:part(ring, "moss", {})
c:fillMask(c:line({{14,28},{18,18},{28,12}}, 1), "#24544a")
c:part(c:poly{ {12,44},{20,40},{24,50},{18,60},{10,54} }, "moss", {})
c:eyeLocked(24, 25)
c:eyeLocked(35, 25)
c:paint({ "iii" }, 30, 33, { i = "#2b1c26" })
c:px(4, 10, "#b9e2f5")
c:px(56, 14, "#b9e2f5")
c:px(52, 8, "#e4f6ff")
c:px(6, 36, "#b9e2f5")
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-hcr-3-yard.aseprite", png = out .. "pl-hcr-3-yard.png" }
