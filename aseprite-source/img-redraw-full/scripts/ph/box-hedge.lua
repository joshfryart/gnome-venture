local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local block = c:rrect(8, 18, 55, 51, 5)
local p = c:build{
  { "block", block, GV.ramp("#58a03e") },
  { "c2", c:ellipse(38, 33, 7, 7), GV.ramp("#2e5a2c"), { gloss = false } },
  { "c1", c:ellipse(20, 29, 6, 6), GV.ramp("#7ab55c") },
  { "c3", c:ellipse(47, 25, 5, 5), GV.ramp("#7ab55c") },
}
-- clip lines across the face
c:fill(c:line({ { 13, 43 }, { 22, 44 }, { 32, 44 }, { 42, 44 }, { 50, 43 } }, 1), "#2f5a2a")
c:fill(c:line({ { 16, 47 }, { 26, 48 }, { 38, 48 }, { 47, 47 } }, 1), "#2f5a2a")
c:ground(31.5, 53, 18, 1.5)

local t = c:save(O .. "aseprite/ph/box-hedge.aseprite", O .. "png/ph/box-hedge.png")
print(GV.report(t))
