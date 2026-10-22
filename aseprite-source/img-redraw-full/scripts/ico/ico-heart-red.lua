local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local m = c:ellipse(21, 24, 12, 12)
m:add(c:ellipse(43, 24, 12, 12))
m:add(c:poly({ {9.5, 26}, {55.5, 26}, {32.5, 57} }))
c:part(m, "red", { gloss = { 17, 18 } })
local t = c:save(O .. "aseprite/ico/ico-heart-red.aseprite", O .. "png/ico/ico-heart-red.png")
print(GV.report(t))
