local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cream = GV.ramp("#f8eed2")
c:build{
  { "left",  c:ellipse(21.5, 32, 10, 15), cream },
  { "right", c:ellipse(41.5, 32, 10, 15), cream },
}
local P = "#2a1a10"
c:fill(c:ellipse(23.5, 38, 5.5, 6), P)
c:fill(c:ellipse(43.5, 38, 5.5, 6), P)
c:fill(c:rect(20, 34, 21, 35), "#fff3c8")
c:fill(c:rect(40, 34, 41, 35), "#fff3c8")
local t = c:save(O .. "aseprite/ico/ico-eyes.aseprite", O .. "png/ico/ico-eyes.png")
print(GV.report(t))
