local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local teal = c:line({ {11, 16}, {40, 41} }, 7):add(c:ellipse(11, 16, 3.5))
teal:add(c:poly({ {57, 55}, {35, 51}, {51, 34} }))
local green = c:line({ {11, 48}, {40, 23} }, 7):add(c:ellipse(11, 48, 3.5))
green:add(c:poly({ {57, 9}, {35, 13}, {51, 30} }))
c:build{
  { "teal", teal, "water" },
  { "green", green, GV.ramp("#6a9a3a") },
}
local t = c:save(O .. "aseprite/ico/ico-shuffle.aseprite", O .. "png/ico/ico-shuffle.png")
print(GV.report(t))
