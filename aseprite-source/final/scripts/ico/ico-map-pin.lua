local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local pin = c:ellipse(31.5, 25, 14.5, 14.5)
pin:add(c:poly({ {18, 31}, {46, 31}, {33.5, 54}, {30.5, 54} }))
local p = c:build{ { "pin", pin, "red", { gloss = { 21, 16 } } } }
c:fill(c:ellipse(31.5, 25, 7, 7), "#4a2c1a")
c:fill(c:ellipse(31.5, 25, 6, 6), "#e9b98a")
c:fill(c:ellipse(31, 24.5, 5.5, 5.5), "#f8eed2")
c:px(29, 21, "#fff3c8"); c:px(28, 22, "#fff3c8")
local t = c:save(O .. "aseprite/ico/ico-map-pin.aseprite", O .. "png/ico/ico-map-pin.png")
print(GV.report(t))
