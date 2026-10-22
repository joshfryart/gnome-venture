local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local drop = c:ellipse(31.5, 39, 16, 14)
drop:add(c:poly({ {31, 7}, {33, 7}, {46, 32}, {17, 32} }))
local puddle = c:ellipse(31.5, 51, 20, 4)
local p = c:build{
  { "puddle", puddle, GV.ramp("#4a8a3e"), { gloss = false } },
  { "drop", drop, "moss", { gloss = { 22, 22 } } },
  { "bubble", c:ellipse(48.5, 21.5, 3.5, 3.5), GV.ramp("#c8d77a"), { gloss = false, flat = true } },
}
c:paint({ "d......d", ".dddddd." }, 24, 42, { d = "#2f5a2a" })
c:px(24, 32, "#c8d77a"); c:px(25, 31, "#c8d77a")
c:ground(31.5, 54, 18, 1.5)
local t = c:save(O .. "aseprite/ph/leech-slime.aseprite", O .. "png/ph/leech-slime.png")
print(GV.report(t))
