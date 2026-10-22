local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local metal = GV.ramp("#968f96")
local head = c:ellipse(31.5, 20, 17.5, 13):cut(c:ellipse(31.5, 20, 12.5, 8)):cut(c:rect(0, 0, 63, 19))
head:add(c:rrect(14, 6, 19, 24, 3)); head:add(c:rrect(44, 6, 49, 24, 3))
c:build{
  { "shaft", c:rrect(28, 30, 35, 57, 4), "wood" },
  { "head",  head, metal, { gloss = { 15, 9 } } },
  { "mid",   c:rrect(29, 6, 34, 30, 3), metal },
  { "collar", c:rrect(26, 29, 37, 35, 1), GV.ramp("#8b8f96") },
}
local t = c:save(O .. "aseprite/ico/ico-fork.aseprite", O .. "png/ico/ico-fork.png")
print(GV.report(t))
