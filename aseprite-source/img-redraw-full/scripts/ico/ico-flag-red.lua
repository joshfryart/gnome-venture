local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
c:build{
  { "pole", c:rect(16, 13, 21, 51), "wood", { gloss = { 17, 17 } } },
  { "flag", c:poly({ { 22, 15 }, { 52, 15 }, { 41, 26 }, { 52, 37 }, { 22, 37 } }), "red" },
  { "cap", c:ellipse(18.5, 11.5, 3.5, 3), "gold", { flat = true } },
}
c:seam({ { 25, 17 }, { 25, 34 } })
local t = c:save(O .. "aseprite/ico/ico-flag-red.aseprite", O .. "png/ico/ico-flag-red.png")
print(GV.report(t))
