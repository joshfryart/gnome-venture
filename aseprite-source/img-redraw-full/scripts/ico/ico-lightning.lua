local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local bolt = c:poly({ {40,7}, {12,37}, {28,37}, {21,59}, {53,24}, {36,24}, {47,7} })
c:build{ { "bolt", bolt, "gold", { gloss = { 37, 13 } } } }
local t = c:save(O .. "aseprite/ico/ico-lightning.aseprite", O .. "png/ico/ico-lightning.png")
print(GV.report(t))
