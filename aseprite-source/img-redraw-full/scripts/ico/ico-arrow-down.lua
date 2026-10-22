local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local W = GV.ramp("#3f93b2")
local shaft = c:rrect(22, 9, 41, 36, 4)
local head = c:poly({ {10, 33}, {54, 33}, {34, 56}, {30, 56} })
head = head:shrink(1):grow(1):closed(2)
local p = c:build{
  { "shaft", shaft, W, { light = shaft:copy():add(head) } },
  { "head", head, W, { light = shaft:copy():add(head) } },
}
c:fill(c:rect(25, 15, 26, 30), W.rim)
local t = c:save(O .. "aseprite/ico/ico-arrow-down.aseprite", O .. "png/ico/ico-arrow-down.png")
print(GV.report(t))
