local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- broad teardrop leaf, tip leaning right
local leaf = c:poly({ {39,6}, {41,8}, {45,15}, {49,23}, {50,31}, {49,39}, {45,46}, {38,52}, {32,57}, {31,57},
                      {24,51}, {18,45}, {14,37}, {14,29}, {18,21}, {25,14}, {33,9} })
c:build{ { "leaf", leaf, GV.ramp("#58a03e") } }
local V = "#2e5a2c"
local veins = c:line({ {32,52}, {33,34}, {35,20}, {36,14} }, 2)
veins:add(c:line({ {32,40}, {22,32} }, 2))
veins:add(c:line({ {33,31}, {42,23} }, 2))
veins:add(c:line({ {32,46}, {24,40} }, 2))
veins:add(c:line({ {33,40}, {42,33} }, 2))
veins:clip(leaf:shrink(3))
c:fill(veins, V)
local t = c:save(O .. "aseprite/ph/rooibos.aseprite", O .. "png/ph/rooibos.png")
print(GV.report(t))
