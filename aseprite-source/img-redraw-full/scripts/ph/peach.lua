local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fruit = c:ellipse(32, 37, 19, 18)
fruit:add(c:ellipse(26, 24, 7, 5)); fruit:add(c:ellipse(38, 24, 7, 5))
fruit:cut(c:rect(31, 18, 32, 20))
local blush = fruit:copy():clip(c:ellipse(24, 30, 12, 11)):cut(c:ellipse(28, 34, 11, 10))
local leaf = c:poly({ {31,17},{27,13},{22,9},{20,7},{24,8},{29,10},{33,14} })
leaf:add(c:ellipse(26, 12, 3.5, 2.5))
local p = c:build{
  { "stem", c:rect(31, 13, 33, 20), GV.ramp("#2e5a2c"), { flat = true } },
  { "leaf", leaf, GV.ramp("#58a03e"), { gloss = false } },
  { "fruit", fruit, GV.ramp("#f08a24"), { gloss = { 23, 27 } } },
}
blush:each(function(x, y) local v = c:get(x, y); if v then c:px(x, y, "#e46a9b") end end)
c:gloss(c:ellipse(23, 27, 3, 2), GV.ramp("#f08a24"), { 23, 27 })
local cl = c:line({ {32,21},{33,28},{33,36},{32,44},{30,50} }, 2):clip(fruit:shrink(2))
c:fill(cl, "#b8452f")
c:ground(32, 56, 16, 1.5)
local t = c:save(O .. "aseprite/ph/peach.aseprite", O .. "png/ph/peach.png")
print(GV.report(t))
