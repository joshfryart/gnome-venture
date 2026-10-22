local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local brown = GV.ramp("#a8622e")
-- main pad: wide, slightly heart-ish (three lobes on the bottom)
local pad = c:ellipse(31.5, 44, 14, 10)
pad:add(c:ellipse(24, 47, 8, 7)):add(c:ellipse(39, 47, 8, 7))
c:build{
  { "pad",  pad, brown },
  { "t1",   c:ellipse(14, 30, 5.5, 6.5), brown },
  { "t2",   c:ellipse(25, 19, 6, 7.5), brown },
  { "t3",   c:ellipse(38, 19, 6, 7.5), brown },
  { "t4",   c:ellipse(49, 30, 5.5, 6.5), brown },
}
local t = c:save(O .. "aseprite/ico/ico-paw.aseprite", O .. "png/ico/ico-paw.png")
print(GV.report(t))
