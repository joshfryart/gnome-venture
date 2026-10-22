local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local head = c:poly({ {8,32}, {32,8}, {32,57} })
head:add(c:poly({ {9,32}, {32,9}, {32,56} }))
local shaft = c:rrect(30, 22, 56, 42, 2)
c:build{
  { "shaft", shaft, GV.ramp("#3f93b2") },
  { "head", head, GV.ramp("#3f93b2"), { gloss = { 19, 29 } } },
}
c:seam({ {36, 32}, {53, 32} })
local t = c:save(O .. "aseprite/ico/ico-arrow-left.aseprite", O .. "png/ico/ico-arrow-left.png")
print(GV.report(t))
