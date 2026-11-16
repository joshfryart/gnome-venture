-- Moonpale Mantle (pl-gwk-3), yard 64x64. Haiku first pass.
-- Seedkeeper, common. A pale scrap of night-blue cloth with a moon on its front.
-- quirk: a pale glow ring around the moon.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-gwk-3-yard" }
c:part(c:rect(31, 8, 33, 11), "wood", {})
c:part(c:poly{ {14,12}, {50,12}, {54,34}, {50,46}, {44,58}, {36,50}, {32,60}, {28,50}, {20,58}, {14,46}, {10,34} }, "dusk", {})
local halo = c:ellipse(32, 40, 10, 10); halo:cut(c:ellipse(32, 40, 8, 8))
c:part(halo, "sky", { noshade = true })
c:part(c:ellipse(32, 40, 7, 7), "sky", {})
c:eyeLocked(23, 19)
c:eyeLocked(36, 19)
c:paint({ "iiiii" }, 30, 29, { i = "#2b1c26" })
c:sparkle(46, 24)
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-gwk-3-yard.aseprite", png = out .. "pl-gwk-3-yard.png" }
