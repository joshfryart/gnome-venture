local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local green = GV.ramp("#58a03e")
local stem = c:line({ {32, 40}, {33, 47}, {35, 52}, {38, 55} }, 5)
local whole = c:ellipse(32, 19, 10):add(c:ellipse(20.5, 32, 10)):add(c:ellipse(43.5, 32, 10))
c:build{
  { "stem",   stem, GV.ramp("#2e5a2c"), { gloss = false } },
  { "top",    c:ellipse(32, 19, 10),   green, { light = whole } },
  { "left",   c:ellipse(20.5, 32, 10), green, { light = whole } },
  { "right",  c:ellipse(43.5, 32, 10), green, { light = whole, gloss = false } },
  { "centre", c:ellipse(32, 29, 7),    green, { light = whole, gloss = false } },
}
-- leaf creases toward the centre
c:fill(c:line({ {32, 15}, {32, 22} }, 2), "#2f5a2a")
c:fill(c:line({ {15, 33}, {22, 31} }, 2), "#2f5a2a")
c:fill(c:line({ {48, 33}, {41, 31} }, 2), "#2f5a2a")
local t = c:save(O .. "aseprite/ico/ico-clover.aseprite", O .. "png/ico/ico-clover.png")
print(GV.report(t))
