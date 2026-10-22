local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local box = c:rrect(13, 25, 51, 55, 4)
local lid = c:poly({ {12, 18}, {52, 11}, {54, 12}, {54, 23}, {12, 30}, {10, 29}, {10, 19} })
local hinge = c:rect(10, 26, 13, 29):add(c:rect(10, 20, 13, 23))
local ring = c:rrect(17, 33, 47, 52, 5)
local win = c:rrect(19, 35, 45, 50, 4)
c:build{
  { "box", box, "stone" },
  { "lid", lid, GV.ramp("#c9c5bc"), { light = box:copy():add(lid), gloss = { 15, 19 } } },
  { "hinge", hinge, GV.ramp("#5b6470"), { flat = true } },
  { "ring", ring, "gold", { gloss = false } },
  { "win", win, GV.ramp("#f4f0e0"), { gloss = false, rim = false } },
  { "stem", c:rect(31, 42, 32, 49), GV.ramp("#2e5a2c"), { flat = true } },
  { "leaf", c:ellipse(35.5, 46.5, 3, 1.5), GV.ramp("#58a03e"), { flat = true } },
  { "petL", c:ellipse(27, 40, 4.5, 4), GV.ramp("#e0501f"), { flat = true } },
  { "petR", c:ellipse(37, 40, 4.5, 4), GV.ramp("#d6322b"), { flat = true } },
  { "petT", c:ellipse(32, 38, 3.5, 3), GV.ramp("#f08a24"), { flat = true } },
}
-- dark gap: wedge between slanted lid and box top
local gap = c:poly({ {14, 28}, {51, 22}, {51, 28}, {14, 31} }):clip(box):cut(lid)
c:fill(gap, "#2a1a10")
c:fill(c:rect(31, 40, 33, 41), "#35161f")
c:seam({ {16, 27}, {50, 21} })
c:button(30, 15)
local t = c:save(O .. "aseprite/ph/corn-poppy-seed.aseprite", O .. "png/ph/corn-poppy-seed.png")
print(GV.report(t))
