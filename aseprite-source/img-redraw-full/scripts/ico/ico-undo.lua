local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local tail = c:ellipse(38, 38, 14.5):cut(c:ellipse(38, 38, 7.5)):cut(c:rect(0, 0, 37, 63))
tail:add(c:rect(23, 24, 38, 30)):add(c:rect(24, 46, 38, 52)):add(c:ellipse(24, 49, 3.5, 3.5))
c:build{
  { "tail",  tail, "#3f93b2" },
  { "arrow", c:poly({ {11,27},{28,12},{28,43} }), "#3f93b2" },
}
local t = c:save(O .. "aseprite/ico/ico-undo.aseprite", O .. "png/ico/ico-undo.png")
print(GV.report(t))
