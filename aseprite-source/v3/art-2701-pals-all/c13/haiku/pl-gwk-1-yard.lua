-- Fang Chip (pl-gwk-1), yard 64x64. Haiku first pass.
-- Thornblade, common. A chipped ivory fang with a face on it.
-- quirk: a little moon in the top left; the chip notch on the right edge.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-gwk-1-yard" }
local moon = c:ellipse(9, 9, 5, 5); moon:cut(c:ellipse(12, 6, 4, 4))
c:part(moon, "sky", {})
local fang = c:poly{ {18,8}, {46,8}, {45,28}, {38,48}, {33,57}, {28,50}, {21,30} }
fang:cut(c:poly{ {42,16}, {48,21}, {44,25} })
c:part(fang, "skinA", {})
c:eyeLocked(24, 15)
c:eyeLocked(36, 15)
c:paint({ "i.i.i" }, 27, 28, { i = "#2b1c26" })
c:part(c:rect(31, 40, 32, 46), "skinB", { noshade = true })
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-gwk-1-yard.aseprite", png = out .. "pl-gwk-1-yard.png" }
