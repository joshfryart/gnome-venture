local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local m = c:rrect(10, 22, 45, 57, 3)
m:add(c:ellipse(25, 17, 7, 7)); m:add(c:rect(21, 20, 29, 23))
m:add(c:ellipse(50, 41, 7, 7)); m:add(c:rect(43, 37, 47, 45))
c:build{
  { "piece", m, GV.ramp("#4a7fb0", { shade = "#2f6290" }), { gloss = { 21, 13 } } },
}
local t = c:save(O .. "aseprite/ico/ico-puzzle.aseprite", O .. "png/ico/ico-puzzle.png")
print(GV.report(t))
