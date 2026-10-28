-- ico-jigsaw-box: a jigsaw box (Library). Plum box seen from above-front, its picture lid lifted and tilted
-- up on the left so coloured pieces peek out. Not ico-box (the brown parcel cube used for 📦).
-- Run: python3 aseprite-source/tools/aseshim.py aseprite-source/final/scripts/ico/ico-jigsaw-box.lua
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ico/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local plum  = GV.ramp("#8a4a8a", { shade = "#62305e", deep = "#3e1e40", rim = "#b070a8" })
-- box: front face, right side, and the dark inside seen over the front rim
local front = c:rect(7, 38, 48, 54)
local side  = c:poly({ {49, 38}, {54, 33}, {54, 49}, {49, 55} })
local inside = c:poly({ {7, 38}, {49, 38}, {54, 33}, {12, 33} })
c:build{
  { "inside", inside, GV.ramp("#3e1e40", { shade = "#2a1a10", rim = "#5a3058" }), { gloss = false, flat = true } },
  { "front", front, plum, { gloss = { 11, 41 } } },
  { "side", side, GV.ramp("#62305e", { shade = "#3e1e40", rim = "#8a4a8a" }), { gloss = false, flat = true } },
}
-- pieces peeking over the rim (left, where the lid is lifted)
c:part(c:rect(10, 31, 15, 37):add(c:ellipse(12.5, 29.5, 2)), GV.ramp("#7ab55c"), { gloss = false, flat = true })
c:part(c:rect(18, 33, 23, 37):add(c:ellipse(24, 35, 2)), GV.ramp("#e8a317"), { gloss = false, flat = true })
-- lid: picture top (sky + hill) tilted up on the left, resting on the right rim, with its plum edge band
local lidTop  = c:poly({ {11, 11}, {51, 18}, {55, 29}, {15, 22} })
local lidEdge = c:poly({ {15, 22}, {55, 29}, {55, 34}, {15, 27} })
local p = c:build{
  { "lidTop",  lidTop, GV.ramp("#7cc0e2", { shade = "#4f8fc0" }), { gloss = false, flat = true } },
  { "lidEdge", lidEdge, plum, { gloss = false } },
}
-- the picture on the lid: a green hill on the lower part of the lid top
local hill = c:ellipse(40, 33, 20, 10):clip(lidTop)
c:fill(hill, "#7ab55c")
c:fill(c:ellipse(41, 34, 20, 10):clip(lidTop):cut(c:ellipse(40, 33, 20, 10)), "#4a8a3e")
c:paint({ ".s.", "sss", ".s." }, 22, 15, { s = "#f5cf6a" })
-- gold seam on the box front (the lid line it closes onto)
c:seam({ { 8, 41 }, { 47, 41 } })
local t = c:save(D .. "final/aseprite/ico/ico-jigsaw-box.aseprite", PNG .. "ico-jigsaw-box.png")
print("ico-jigsaw-box", GV.report(t))
