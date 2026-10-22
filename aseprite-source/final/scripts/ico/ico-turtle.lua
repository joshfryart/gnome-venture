local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local shell = c:ellipse(26.5, 39, 16, 19):cut(c:rect(0, 39, 63, 63))
local legs = c:rrect(15, 35, 22, 46, 3):add(c:rrect(30, 35, 37, 46, 3))
c:build{
  { "legs",  legs, "#58a03e" },
  { "head",  c:ellipse(46, 29, 6.5, 6), "#58a03e" },
  { "shell", shell, "#2e5a2c", { gloss = { 16, 25 } } },
  { "plate", c:poly({ {26,23},{33,27},{33,34},{26,38},{19,34},{19,27} }), "#58a03e", { gloss = false } },
  { "bumpL", c:ellipse(14, 36, 3.5, 3), "#58a03e", { flat = true } },
  { "bumpR", c:ellipse(38, 36, 3.5, 3), "#58a03e", { flat = true } },
}
c:eye(46, 26, true)
c:ground(27, 47, 15, 1.5)
local t = c:save(O .. "aseprite/ico/ico-turtle.aseprite", O .. "png/ico/ico-turtle.png")
print(GV.report(t))
