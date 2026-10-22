local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cloud = c:ellipse(36, 33, 10, 10):add(c:ellipse(47, 36, 8, 8)):add(c:rrect(22, 36, 55, 45, 5)):add(c:ellipse(25, 39, 5, 5))
c:build{
  { "sun",   c:ellipse(21, 21, 12, 12), GV.ramp("#f2b830") },
  { "rainL", c:line({ { 31, 47 }, { 29, 52 } }, 4), "water", { gloss = false } },
  { "rainR", c:line({ { 45, 47 }, { 43, 52 } }, 4), "water", { gloss = false } },
  { "cloud", cloud, GV.ramp("#8c9ca6"), { gloss = { 31, 26 } } },
}
local t = c:save(O .. "aseprite/ico/ico-sun-rain.aseprite", O .. "png/ico/ico-sun-rain.png")
print(GV.report(t))
