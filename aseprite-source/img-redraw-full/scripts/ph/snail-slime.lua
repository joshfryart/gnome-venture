local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bottle = c:ellipse(32, 40, 16, 15):add(c:rect(26, 14, 38, 27))
local slime = c:ellipse(32, 40, 14, 13):cut(c:rect(0, 0, 63, 29))
local cork = c:rrect(25, 7, 39, 16, 2)
local drop = c:ellipse(51, 54, 2, 2.5)
local p = c:build{
  { "bottle", bottle, "glass", { gloss = false } },
  { "slime", slime, "moss", { contour = false, contact = false, rim = false, gloss = { 22, 33 } } },
  { "cork", cork, "wood" },
  { "drop", drop, "moss", { flat = true } },
}
-- fill surface
c:fill(c:rect(19, 30, 45, 31):clip(slime), "#a4b86a")
-- spiral swirl inside
c:fill(c:line({ {31, 42}, {33, 41}, {34, 43}, {32, 45}, {29, 44}, {28, 41}, {30, 38}, {34, 38}, {37, 41}, {36, 46}, {33, 48} }, 2), "#4a8a3e")
-- glass edge on the left of the belly
local ring = c:ellipse(32, 40, 16, 15):cut(c:ellipse(33, 40, 15, 15)):clip(c:rect(0, 28, 25, 50))
c:fill(ring:clip(c:ellipse(32, 40, 15, 14)), "#c8ecdc")
c:fill(c:rect(28, 17, 29, 24), "#c8ecdc")
c:seam({ {26, 24}, {38, 24} })
local t = c:save(O .. "aseprite/ph/snail-slime.aseprite", O .. "png/ph/snail-slime.png")
print(GV.report(t))
