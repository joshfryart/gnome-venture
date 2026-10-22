local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local blade = c:ellipse(32, 39, 21, 15)
blade:add(c:poly({ {32,7}, {33,7}, {53,37}, {11,37} }))
c:build{ { "blade", blade, GV.ramp("#58a03e") } }
local V = "#2f5a2a"
c:fill(c:line({ {15,35}, {24,32}, {32,31}, {41,32}, {49,34} }, 2):clip(blade:shrink(3)), "#4a8a3e")
c:fill(c:line({ {32,16}, {32,51} }, 3), V)
c:fill(c:line({ {31,38}, {23,30} }, 3), V)
c:fill(c:line({ {31,46}, {24,39} }, 3), V)
c:fill(c:line({ {33,30}, {40,23} }, 3), V)
c:fill(c:line({ {33,42}, {41,34} }, 3), V)
local t = c:save(O .. "aseprite/ico/ico-leafy-green.aseprite", O .. "png/ico/ico-leafy-green.png")
print(GV.report(t))
