local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local m = c:rrect(26, 13, 37, 50, 5)
m:add(c:rrect(13, 26, 50, 37, 5))
m = m:closed(2)
c:build{ { "plus", m, GV.ramp("#58a03e", {shade="#4a8a3e"}), { gloss = {29, 17} } } }
local t = c:save(O .. "aseprite/ico/ico-plus.aseprite", O .. "png/ico/ico-plus.png")
print(GV.report(t))
