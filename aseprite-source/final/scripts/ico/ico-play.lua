local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local tri = c:poly({ {16, 11}, {51, 32}, {16, 53} })
tri = tri:shrink(3):grow(3)
c:build{ { "tri", tri, GV.ramp("#58a03e", {shade="#4a8a3e"}), { stitch = { side = "lit" }, gloss = {22, 20} } } }
local t = c:save(O .. "aseprite/ico/ico-play.aseprite", O .. "png/ico/ico-play.png")
print(GV.report(t))
