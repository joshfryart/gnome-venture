-- Fang Chip (pl-gwk-1), perch 36x36. Haiku first pass.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "pl-gwk-1-perch" }
c:part(c:ellipse(3, 3, 2, 2), "sky", {})
local fang = c:poly{ {9,4}, {27,4}, {26,18}, {20,31}, {16,31}, {10,18} }
fang:cut(c:poly{ {24,9}, {28,11}, {25,13} })
c:part(fang, "skinA", {})
c:eyeSmall(13, 10)
c:eyeSmall(21, 10)
c:paint({ "i.i" }, 15, 20, { i = "#2b1c26" })
c:finish{ outline = true }
HP.assertClean(c)
local out = app.params.out or (dir .. "/")
c:save{ aseprite = out .. "pl-gwk-1-perch.aseprite", png = out .. "pl-gwk-1-perch.png" }
