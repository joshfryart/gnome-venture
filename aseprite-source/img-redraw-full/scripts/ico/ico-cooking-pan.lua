local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local pan = c:ellipse(25.5, 31.5, 15)
local handle = c:rrect(38, 28, 52, 35, 3)
-- egg white: a lumpy blob, not a perfect circle
local white = c:ellipse(25, 30.5, 11, 10):add(c:ellipse(28, 34, 8, 7)):add(c:ellipse(20, 35, 6, 4))

local p = c:build{
  { "handle", handle, "wood" },
  { "pan",    pan,    GV.ramp("#3a2a22"), { light = pan } },
  { "white",  white,  GV.ramp("#fffaf0"), { gloss = false, contour = "#4a2c1a" } },
  { "yolk",   c:ellipse(24.5, 30.5, 5), "gold" },
}
-- inner wall of the pan: a lighter ring 3 px in to show depth
c:fill(c:line({ {48,30}, {50,30} }, 2), "#5e2f1e")
c:fill(c:rect(49, 30, 50, 32), "#8a4a1c")
c:px(49, 31, "#4a2c1a")
local t = c:save(O .. "aseprite/ico/ico-cooking-pan.aseprite", O .. "png/ico/ico-cooking-pan.png")
print(GV.report(t))
