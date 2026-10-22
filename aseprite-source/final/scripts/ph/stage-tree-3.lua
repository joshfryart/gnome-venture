local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local crownAll = c:ellipse(32, 20.5, 13):add(c:ellipse(23.5, 27, 8.5)):add(c:ellipse(40.5, 26, 8.5))
local p = c:build{
  { "mound", c:ellipse(31.5, 47, 19, 5.5), GV.ramp("#8c4a1a") },
  { "mtop",  c:ellipse(31.5, 45.5, 14, 3), GV.ramp("#a5663a"), { flat = true } },
  { "trunk", c:rrect(30, 28, 33, 46, 1), GV.ramp("#c4925f") },
  { "left",  c:ellipse(23.5, 27, 8.5), GV.ramp("#2e5a2c"), { light = crownAll, gloss = false } },
  { "right", c:ellipse(40.5, 26, 8.5), GV.ramp("#7ab55c"), { light = crownAll } },
  { "crown", c:ellipse(32, 20.5, 13), GV.ramp("#58a03e"), { light = crownAll, gloss = { 24, 12 } } },
}
-- leaf beans on the crown
c:spot(c:ellipse(35, 15, 1.5, 1), "#4a8a3e", "#7ab55c")
c:spot(c:ellipse(28, 24, 1.5, 1), "#4a8a3e", "#7ab55c")
c:spot(c:ellipse(39, 23, 1.5, 1), "#4a8a3e", "#7ab55c")

local t = c:save(O .. "aseprite/ph/stage-tree-3.aseprite", O .. "png/ph/stage-tree-3.png")
print(GV.report(t))
