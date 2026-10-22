local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dark = GV.ramp("#b07a10")
c:build{
  { "belly", c:ellipse(32, 39, 18, 15), "gold" },
  { "neck",  c:rrect(17, 21, 47, 27, 3), dark, { gloss = false } },
  { "lid",   c:ellipse(32, 20, 15, 7):cut(c:rect(0, 24, 63, 63)), "gold" },
  { "knob",  c:ellipse(32, 11, 4, 4), dark },
}
c:seam({ {19, 24}, {45, 24} })
c:button(30, 22)
-- seed emblem on the belly
c:paint({
  "...dd...",
  "..dddd..",
  ".ddsddd.",
  ".ddsddd.",
  "dddsdddd",
  "dddsdddd",
  "dddsdddd",
  ".ddsddd.",
  ".ddsddd.",
  "..dddd..",
  "...dd...",
}, 29, 35, { d = "#5a3008", s = "#f5cf6a" })
local t = c:save(O .. "aseprite/ph/mexican-sunflower-seed.aseprite", O .. "png/ph/mexican-sunflower-seed.png")
print(GV.report(t))
