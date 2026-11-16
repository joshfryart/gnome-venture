-- Pawprint Cuff (pl-gwk-2), yard 64x64. Haiku first pass.
-- Rootwarden, common. A soft snow cuff, puffy and round.
-- quirk: one perfect pawprint pressed into its lower right side.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "pl-gwk-2-yard" }
c:part(c:rrect(12, 16, 52, 52, 16), "sky", {})
c:part(c:ellipse(43, 42, 4, 3), "stone", { noshade = true })
c:part(c:ellipse(38, 36, 1.5, 1.5), "stone", { noshade = true })
c:part(c:ellipse(41, 35, 1.5, 1.5), "stone", { noshade = true })
c:part(c:ellipse(44, 36, 1.5, 1.5), "stone", { noshade = true })
c:part(c:ellipse(47, 39, 1.5, 1.5), "stone", { noshade = true })
c:eyeLocked(23, 27)
c:eyeLocked(37, 27)
c:cheek(20, 35)
c:cheek(41, 35)
c:paint({ "iii" }, 30, 35, { i = "#2b1c26" })
c:sparkle(16, 22)
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-gwk-2-yard.aseprite", png = out .. "pl-gwk-2-yard.png" }
