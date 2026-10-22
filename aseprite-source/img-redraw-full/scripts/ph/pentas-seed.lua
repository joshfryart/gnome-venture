local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local belly = c:ellipse(32, 41, 18, 15)
belly:add(c:ellipse(32, 30, 12, 6))
local neck = c:rrect(25, 20, 39, 27, 2)
local ruffle = c:poly({ {20, 13}, {45, 13}, {40, 21}, {25, 21} })
ruffle:add(c:ellipse(23.5, 13, 4, 3)):add(c:ellipse(32.5, 12, 4, 3)):add(c:ellipse(41.5, 13, 4, 3))
local p = c:build{
  { "belly", belly, "water", { stitch = true } },
  { "neck", neck, "water" },
  { "ruffle", ruffle, "#8fcbd8" },
  { "medal", c:ellipse(32, 43, 9, 9), "#f4f0e0", { pale = true, gloss = false } },
  { "seed", c:ellipse(32, 43, 6, 6), "#3f93b2", { gloss = { 29, 40 } } },
  { "leaf", c:ellipse(38.5, 35.5, 3, 2), "#58a03e", { flat = true } },
}
-- drawstring across the neck with tails and beads
c:fill(c:rect(23, 22, 41, 23), "#f5cf6a")
c:fill(c:line({ {23, 23}, {21, 27}, {20, 30} }, 2), "#f5cf6a")
c:fill(c:line({ {41, 23}, {43, 27}, {44, 30} }, 2), "#f5cf6a")
c:part(c:ellipse(20, 32, 1.5, 1.5), "gold", { flat = true })
c:part(c:ellipse(45, 32, 1.5, 1.5), "gold", { flat = true })
c:fill(c:rect(23, 23, 41, 23), "#e8a317")
local t = c:save(O .. "aseprite/ph/pentas-seed.aseprite", O .. "png/ph/pentas-seed.png")
print(GV.report(t))
