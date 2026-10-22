local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bowl = c:ellipse(31.5, 28, 24, 23):clip(c:rect(0, 28, 63, 63))
bowl:add(c:rrect(26, 48, 37, 53, 1))
local mound = c:ellipse(31.5, 29, 21, 17):clip(c:rect(0, 0, 63, 29))
mound:add(c:ellipse(21, 24, 10, 9)):add(c:ellipse(42, 24, 10, 9))
mound = mound:clip(c:rect(0, 0, 63, 29))
local p = c:build{
  { "greens", mound, "#f5cf6a" },
  { "bowl", bowl, GV.ramp("#f4f0e0"), { gloss = { 16, 34 } } },
  { "rim", c:rrect(7, 26, 56, 30, 2), GV.ramp("#d6c9b6"), { flat = true } },
  { "tan", c:ellipse(22, 20, 4.5), "#dcb06a", { gloss = { 20, 17 } } },
  { "green", c:ellipse(32.5, 15, 4.5), "moss", { gloss = { 30, 12 } } },
  { "gold", c:ellipse(43, 20, 4), "#e8a317", { gloss = { 41, 18 } } },
}
c:seam({ {9, 28}, {54, 28} })
local t = c:save(O .. "aseprite/ph/goat-cheese-salad.aseprite", O .. "png/ph/goat-cheese-salad.png")
print(GV.report(t))
