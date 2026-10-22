local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local dark = GV.ramp("#3a2f3a")
local legs = c:line({ {20,31}, {14,28}, {12,24} }, 3)
  :add(c:line({ {43,31}, {49,28}, {51,24} }, 3))
  :add(c:line({ {19,39}, {12,40} }, 3)):add(c:line({ {44,39}, {51,40} }, 3))
  :add(c:line({ {21,47}, {16,51}, {15,54} }, 3)):add(c:line({ {42,47}, {47,51}, {48,54} }, 3))
local ant = c:line({ {28,15}, {24,11} }, 3):add(c:line({ {35,15}, {39,11} }, 3))
  :add(c:rect(21, 8, 24, 11)):add(c:rect(39, 8, 42, 11))
local shell = c:ellipse(31.5, 38, 14, 15)
c:build{
  { "legs", legs, dark, { flat = true } },
  { "ant",  ant, dark, { flat = true } },
  { "shell", shell, GV.ramp("#2f9a78") },
  { "head", c:ellipse(31.5, 20, 7.5, 6), dark },
}
c:fill(c:rect(31, 27, 32, 52), "#1d4f40")
c:seam({ {33, 32}, {33, 51} })
c:eye(27, 18, true); c:eye(33, 18, true)
local t = c:save(O .. "aseprite/ico/ico-beetle.aseprite", O .. "png/ico/ico-beetle.png")
print(GV.report(t))
