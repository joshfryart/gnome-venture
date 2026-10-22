local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local jetC = GV.ramp("#a9d6ea")
local basin = c:ellipse(31.5, 45, 26, 11)
basin:add(c:rrect(8, 44, 55, 51, 6))
local water = c:ellipse(31.5, 42, 21, 6.5)
local jet = c:rect(30, 19, 33, 41)
local arch = c:line({ {24, 30}, {24, 25}, {26, 21}, {29, 18}, {34, 18}, {37, 21}, {39, 25}, {39, 30} }, 4)

c:build{
  { "basin", basin, GV.ramp("#968f96") },
  { "water", water, GV.ramp("#3f93b2"), { contact = false } },
  { "jet",   jet,   jetC, { gloss = false, flat = true } },
  { "arch",  arch,  jetC, { gloss = { 27, 19 }, cres = 1, deep = 0 } },
}
-- falling drops at the arch ends
c:part(c:rect(24, 34, 26, 35), jetC, { flat = true, contour = false })
c:part(c:rect(38, 34, 40, 35), jetC, { flat = true, contour = false })
-- ripples
c:paint({ "rrrr.......rrrr" }, 17, 41, { r = "#c8ecdc" })
c:paint({ "rrr..........rrr" }, 24, 44, { r = "#c8ecdc" })
-- stone basin lip seam
c:seam({ {9, 49}, {54, 49} })
c:ground(31.5, 57, 22, 1.5)

local t = c:save(O .. "aseprite/ph/fountain.aseprite", O .. "png/ph/fountain.png")
print(GV.report(t))
