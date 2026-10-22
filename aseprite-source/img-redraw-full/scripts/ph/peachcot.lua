local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fruit = c:ellipse(32, 39, 14, 17)
local pink = fruit:copy():clip(c:poly({ {36,18},{64,18},{64,64},{30,64} }))
local gold = fruit:copy():cut(pink)
local leafL = c:poly({ {32,21},{27,16},{22,11},{21,9},{25,10},{30,14},{33,19} })
leafL:add(c:ellipse(26, 14, 3, 2.5))
local leafR = c:poly({ {32,21},{36,16},{41,11},{43,9},{39,10},{34,14},{31,19} })
leafR:add(c:ellipse(38, 14, 3, 2.5))
local p = c:build{
  { "stem", c:rect(31, 15, 33, 22), GV.ramp("#4a2c1a"), { flat = true } },
  { "leafL", leafL, "moss", { gloss = false } },
  { "leafR", leafR, "moss", { gloss = false } },
  { "gold", gold, GV.ramp("#f0a030"), { light = fruit, gloss = { 25, 30 } } },
  { "pink", pink, "petal", { light = fruit, gloss = false } },
}
local cl = c:line({ {33,23},{35,32},{36,42},{35,52} }, 2):clip(fruit:shrink(2))
c:fill(cl, "#b8452f")
c:ground(32, 56, 12, 1.5)
local t = c:save(O .. "aseprite/ph/peachcot.aseprite", O .. "png/ph/peachcot.png")
print(GV.report(t))
