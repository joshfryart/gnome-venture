local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local top   = c:ellipse(32, 23, 11, 7)
local left  = c:ellipse(20.5, 38, 12, 8)
local right = c:ellipse(43.5, 37, 12, 8)
local p = c:build{
  { "top",   top,   GV.ramp("#6a6070") },
  { "left",  left,  GV.ramp("#968f96") },
  { "right", right, GV.ramp("#d6c9b6") },
}
-- chip lines on top cobble
local pal = GV.ramp("#6a6070")
c:px(27, 20, pal.rim); c:px(28, 20, pal.rim); c:px(29, 21, pal.rim)
c:px(36, 25, pal.rim); c:px(37, 26, pal.rim)
c:ground(32, 47, 17, 2.5)
local t = c:save(O .. "aseprite/ph/brick-path.aseprite", O .. "png/ph/brick-path.png")
print(GV.report(t))
