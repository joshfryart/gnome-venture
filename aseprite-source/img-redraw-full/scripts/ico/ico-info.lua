local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local teal = GV.ramp("#3f93b2")
local cream = GV.ramp("#f8eed2")
local p = c:build{
  { "disc", c:ellipse(31.5, 31.5, 20.5, 20.5), teal },
  { "dot", c:ellipse(31.5, 20.5, 4, 4), cream, { gloss = { 30, 18 } } },
  { "stem", c:rrect(27, 28, 36, 45, 2):add(c:rect(25, 28, 30, 31)), cream },
}
local t = c:save(O .. "aseprite/ico/ico-info.aseprite", O .. "png/ico/ico-info.png")
print(GV.report(t))
