local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local head = c:ellipse(31.5, 31.5, 24, 24)
c:build{
  { "head", head, GV.ramp("#e8c547") },
}
-- big locked eyes (7x7 disc, 3x3 pupil) for a chunky icon
local eye = {
  ".ccccc.",
  "ccccccc",
  "ccgpppc",
  "cccpppc",
  "cccpppc",
  "ccccccc",
  ".ccccc.",
}
c:paint(eye, 20, 21, { c = "#f2e4c0", p = "#2a1a10", g = "#f2e4c0" })
c:paint(eye, 37, 21, { c = "#f2e4c0", p = "#2a1a10", g = "#f2e4c0" })
-- wide 3px smile arc with rounded ends
c:paint({
  ".mm.......................mm.",
  "mmmm.....................mmmm",
  "mmmm.....................mmmm",
  ".mmm.....................mmm.",
  "..mmm...................mmm..",
  "...mmm.................mmm...",
  "....mmmm.............mmmm....",
  ".....mmmmm.........mmmmm.....",
  "......mmmmmmmmmmmmmmmmm......",
  "........mmmmmmmmmmmmm........",
  "...........mmmmmmm...........",
}, 17, 35, { m = "#2a1a10" })

local t = c:save(O .. "aseprite/ico/ico-face-smile.aseprite", O .. "png/ico/ico-face-smile.png")
print(GV.report(t))
