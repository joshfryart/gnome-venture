local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local lit = GV.ramp("#6c55c0")
local dark = GV.ramp("#2e2054")
local leaf = c:poly({ {32,20}, {33,13}, {36,8}, {41,5}, {42,9}, {40,15}, {36,19} })
c:build{
  { "stem", c:rrect(30, 15, 33, 25, 1), "#2f5a2a", { flat = true } },
  { "leaf", leaf, "leaf" },
  { "b1", c:ellipse(32, 29, 8.5, 8.5), lit },
  { "b2", c:ellipse(23.5, 38.5, 8.5, 8.5), lit },
  { "b3", c:ellipse(40.5, 38.5, 8.5, 8.5), dark },
  { "b4", c:ellipse(16, 48, 8.5, 8), dark },
  { "b5", c:ellipse(32, 48, 8.5, 8), lit },
  { "b6", c:ellipse(48, 48, 8.5, 8), dark },
}
c:ground(32, 57, 17, 3.5, "#6a4528")
local t = c:save(O .. "aseprite/ph/acai.aseprite", O .. "png/ph/acai.png")
print(GV.report(t))
