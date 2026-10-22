local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local tri = c:poly({ {32, 10}, {54, 52}, {10, 52} }):shrink(3):grow(3)
local yel = GV.ramp("#e8c547")
c:build{
  { "tri", tri, yel, { gloss = { 27, 24 } } },
  { "bar", c:rrect(29, 25, 35, 38, 3), "#3a2418", { flat = true, gloss = false, contour = false, contact = false } },
  { "dot", c:ellipse(32, 44.5, 3.5, 3.5), "#3a2418", { flat = true, gloss = false, contour = false, contact = false } },
}
local t = c:save(O .. "aseprite/ico/ico-warning.aseprite", O .. "png/ico/ico-warning.png")
print(GV.report(t))
