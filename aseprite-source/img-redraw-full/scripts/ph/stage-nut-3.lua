local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local p = c:build{
  { "mound",  c:ellipse(31.5, 48, 18, 4.5), GV.ramp("#8c4a1a") },
  { "top",    c:ellipse(31.5, 46.5, 13, 2.5), GV.ramp("#a5663a"), { contour = false } },
  { "trunk",  c:rect(30, 28, 33, 47), GV.ramp("#c4925f") },
  { "centre", c:ellipse(31.5, 22, 11, 11), GV.ramp("#58a03e") },
  { "left",   c:ellipse(23.5, 27, 7.5, 7.5), GV.ramp("#2f5a2a") },
  { "right",  c:ellipse(39.5, 26, 7.5, 7.5), GV.ramp("#7ab55c") },
}
c:ground(31.5, 51, 15, 1.5)

local t = c:save(O .. "aseprite/ph/stage-nut-3.aseprite", O .. "png/ph/stage-nut-3.png")
print(GV.report(t))
