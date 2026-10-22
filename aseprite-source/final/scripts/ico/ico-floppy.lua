local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local body = c:rrect(9, 9, 54, 54, 5)
body:cut(c:poly({ {48, 9}, {55, 9}, {55, 16} })) -- clipped corner like a real floppy
local p = c:build{
  { "disk",    body, GV.ramp("#3f93b0"), { gloss = { 12, 30 } } },
  { "shutter", c:rect(19, 9, 44, 25), GV.ramp("#968f96"), { gloss = false } },
  { "slot",    c:rect(35, 12, 40, 22), GV.ramp("#f8eed2"), { flat = true, pale = true } },
  { "label",   c:rrect(16, 33, 47, 54, 2):cut(c:rect(16, 53, 47, 54)):add(c:rect(16, 50, 47, 54)), GV.ramp("#f8eed2"), { pale = true, gloss = false } },
}
-- slot edge
c:outline(c:rect(35, 12, 40, 22))
-- label lines
c:fill(c:rect(21, 40, 42, 41), "#8c4a1a")
c:fill(c:rect(21, 46, 36, 47), "#8c4a1a")
-- shutter rivet
c:fill(c:rect(23, 13, 25, 15), "#5b6470")

local t = c:save(O .. "aseprite/ico/ico-floppy.aseprite", O .. "png/ico/ico-floppy.png")
print(GV.report(t))
