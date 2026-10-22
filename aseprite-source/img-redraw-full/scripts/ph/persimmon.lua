local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fruit = c:ellipse(31.5, 37, 18, 14)
local calyx = c:ellipse(31.5, 25, 6, 3.5)
calyx:add(c:poly({ {28,22}, {17,30}, {20,31}, {30,28} }))
calyx:add(c:poly({ {35,22}, {47,30}, {44,31}, {34,28} }))
calyx:add(c:poly({ {28,26}, {31,34}, {33,34}, {36,26} }))
calyx:add(c:poly({ {28,24}, {31,18}, {33,18}, {36,24} }))
local stem = c:rect(30, 13, 32, 21)
c:build{
  { "fruit", fruit, GV.ramp("#f08a24", { shade = "#e0501f" }), { gloss = { 23, 31 } } },
  { "stem", stem, GV.ramp("#2e5a2c"), { flat = true } },
  { "calyx", calyx, GV.ramp("#58a03e"), { gloss = false } },
}
c:px(31, 14, "#4a8a3e")
local t = c:save(O .. "aseprite/ph/persimmon.aseprite", O .. "png/ph/persimmon.png")
print(GV.report(t))
