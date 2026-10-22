local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- knobbly root: inverted wedge with lumps
local root = c:ellipse(32, 26, 14, 8)
root:add(c:poly({ {18, 26}, {46, 26}, {38, 50}, {34, 57}, {30, 57}, {25, 46} }))
root:add(c:ellipse(18, 34, 5, 5))       -- left knuckle
root:add(c:ellipse(45, 40, 5, 4.5))     -- right knuckle
root:add(c:ellipse(25, 45, 4, 4))       -- lower lump
root:add(c:ellipse(32, 54, 3.5, 3))     -- tip
local shootL = c:poly({ {24, 6}, {29, 5}, {33, 14}, {34, 21}, {30, 21}, {26, 13} })
local shootR = c:poly({ {40, 6}, {35, 5}, {31, 14}, {30, 21}, {34, 21}, {38, 13} })
local p = c:build{
  { "shootR", shootR, GV.ramp("#6a9a3a"), { gloss = false } },
  { "shootL", shootL, GV.ramp("#58a03e"), { gloss = false } },
  { "root",   root,   GV.ramp("#dcb06a"), { gloss = { 24, 25 } } },
}
-- ring creases
local d = "#8a4f2a"
c:paint({ ".ddddd.", "d.....d" }, 23, 30, { d = d })
c:paint({ "dddddd", "......" }, 34, 38, { d = d })
c:paint({ ".dddd." }, 27, 47, { d = d })
-- knuckle crease marks
c:paint({ "d", "d" }, 21, 33, { d = d })
c:paint({ "d", "d" }, 42, 40, { d = d })
c:ground(32, 59, 10, 1.5)
local t = c:save(O .. "aseprite/ph/ginger.aseprite", O .. "png/ph/ginger.png")
print(GV.report(t))
