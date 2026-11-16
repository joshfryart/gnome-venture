-- Pawprint Cuff (pl-gwk-2), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-gwk-2-perch" }
c:part(c:rrect(5, 8, 31, 31, 7), "sky", {})
c:part(c:ellipse(23, 24, 2, 2), "stone", { noshade = true })
c:part(c:rect(21, 20, 22, 21), "stone", { noshade = true })
c:eyeSmall(11, 15)
c:eyeSmall(21, 15)
c:paint({ "ii" }, 15, 21, { i = "#2b1c26" })
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-gwk-2-perch.aseprite", png = out .. "pl-gwk-2-perch.png" }
