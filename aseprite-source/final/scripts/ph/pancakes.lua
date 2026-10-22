local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local syrup = c:rrect(13, 27, 51, 33, 3)
syrup:add(c:ellipse(17, 35, 2, 3)); syrup:add(c:ellipse(26.5, 37, 2.5, 4))
syrup:add(c:ellipse(37, 35, 2, 3)); syrup:add(c:ellipse(46.5, 38, 2.5, 4))
local p = c:build{
  { "cake3", c:rrect(11, 45, 53, 53, 4), "#d9a660", { stitch = true } },
  { "cake2", c:rrect(12, 38, 52, 46, 4), "#d9a660" },
  { "cake1", c:rrect(13, 31, 51, 39, 4), "#d9a660" },
  { "syrup", syrup, "water", { gloss = { 17, 29 } } },
  { "candle", c:rrect(30, 15, 33, 28, 1), "#f6b8cf", { flat = true } },
  { "flame", c:ellipse(31.5, 11, 2, 3):add(c:poly({ {31, 5}, {33, 5}, {33, 9}, {31, 9} })), "gold", { flat = true } },
}
c:px(31, 10, GV.R.gold.gloss); c:px(31, 11, GV.R.gold.gloss)
c:seam({ {14, 49}, {50, 49} })
local t = c:save(O .. "aseprite/ph/pancakes.aseprite", O .. "png/ph/pancakes.png")
print(GV.report(t))
