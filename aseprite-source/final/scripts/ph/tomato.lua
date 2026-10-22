local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fruit = c:ellipse(31.5, 37, 18, 16)
local stem = c:rrect(30, 13, 33, 23, 1)
local calyx = c:poly({ {21,22},{28,24},{25,28},{31,26},{32,31},{34,26},{40,28},{37,24},{43,22},{36,22},{32,20},{28,22} })
local leaf = c:poly({ {33,15},{38,9},{45,7},{47,8},{44,13},{38,17},{34,17} })
c:build{
  { "stem", stem, GV.ramp("#2e5a2c") },
  { "leaf", leaf, GV.ramp("#58a03e") },
  { "fruit", fruit, GV.ramp("#d6322b"), { cres = 5 } },
  { "calyx", calyx, GV.ramp("#58a03e"), { flat = true } },
}
c:paint({ "ll", "l." }, 42, 9, { l = "#3e7a2e" })
c:ground(31.5, 54, 14, 1.5)
local t = c:save(O .. "aseprite/ph/tomato.aseprite", O .. "png/ph/tomato.png")
print(GV.report(t))
