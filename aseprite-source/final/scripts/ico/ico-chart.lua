local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.R
local g = GV.ramp("#58a03e", { shade = "#4a8a3e", deep = "#2f5a2a" })
c:build{
  { "b1", c:rrect(11, 39, 20, 52, 2), g },
  { "b2", c:rrect(27, 27, 36, 52, 2), g },
  { "b3", c:rrect(43, 13, 52, 52, 2), g },
}
c:seam({ {13, 42}, {18, 42} }); c:seam({ {29, 30}, {34, 30} }); c:seam({ {45, 16}, {50, 16} })
local t = c:save(O .. "aseprite/ico/ico-chart.aseprite", O .. "png/ico/ico-chart.png")
print("ico-chart " .. GV.report(t))
