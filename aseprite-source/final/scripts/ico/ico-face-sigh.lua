local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local water = GV.ramp("#8cc6da")
local big = c:ellipse(46, 19, 4, 4):add(c:poly({ {43, 17}, {49, 17}, {46, 11} }))
local small = c:ellipse(48, 30, 3, 3):add(c:poly({ {46, 29}, {51, 29}, {48, 25} }))
c:build{
  { "face",  c:ellipse(27, 34, 16, 16), GV.ramp("#e8c547") },
  { "drop1", big, water },
  { "drop2", small, water },
}
local P = "#2a1a10"
c:fill(c:rect(17, 30, 23, 32), P)
c:fill(c:rect(31, 30, 37, 32), P)
c:fill(c:ellipse(27, 42.5, 3.5, 4), P)
local t = c:save(O .. "aseprite/ico/ico-face-sigh.aseprite", O .. "png/ico/ico-face-sigh.png")
print(GV.report(t))
