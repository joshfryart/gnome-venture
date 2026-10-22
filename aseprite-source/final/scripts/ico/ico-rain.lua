local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cloud = c:ellipse(22, 27, 7.5, 7.5):add(c:ellipse(32, 22.5, 9.5, 9.5)):add(c:ellipse(42.5, 27.5, 6.5, 6.5))
cloud:add(c:rrect(13, 26, 51, 35, 5))
local ld = c:build{
  { "cloud", cloud, GV.ramp("#8c9ca6") },
  { "d1", c:line({ {22, 40}, {19, 47} }, 4), "water" },
  { "d2", c:line({ {32, 40}, {29, 47} }, 4), "water" },
  { "d3", c:line({ {42, 40}, {39, 47} }, 4), "water" },
}
local t = c:save(O .. "aseprite/ico/ico-rain.aseprite", O .. "png/ico/ico-rain.png")
print(GV.report(t))
