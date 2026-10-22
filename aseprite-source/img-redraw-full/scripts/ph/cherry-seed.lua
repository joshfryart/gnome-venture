local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lumpy pear sack, left side bulges more
local sack = c:ellipse(31, 42, 20, 13)
sack:add(c:ellipse(27, 44, 16, 11))
sack:add(c:poly({ {24, 21}, {40, 21}, {48, 34}, {14, 36} }))
sack:cut(c:rect(0, 56, 63, 63))
local ears = c:poly({ {23, 9}, {31, 21}, {21, 23} }):add(c:poly({ {41, 9}, {33, 21}, {43, 23} }))
local p = c:build{
  { "ears",  ears, GV.ramp("#9a6b3f") },
  { "sack",  sack, GV.ramp("#c9a96e") },
  { "twine", c:rrect(23, 19, 41, 23, 2), GV.ramp("#7a4a1f"), { gloss = false } },
  { "edge",  c:rrect(20, 29, 43, 50, 5), GV.ramp("#d6322b"), { flat = true } },
  { "patch", c:rrect(22, 31, 41, 48, 4), GV.ramp("#f1ece0"), { gloss = false } },
  { "cherry",c:ellipse(31.5, 41, 6.5, 6.5), GV.ramp("#d6322b"), { gloss = { 28, 37 } } },
  { "stem",  c:rect(31, 31, 32, 35), GV.ramp("#2e5a2c"), { flat = true } },
  { "leaf",  c:ellipse(36.5, 33, 3, 2), GV.ramp("#58a03e"), { flat = true } },
}
c:stitch(p.patch.m)
c:paint({ "kk", "kk" }, 31, 20, { k = "#4a2c1a" })
c:paint({ "w", "w" }, 15, 40, { w = "#7a4a1f" })
c:paint({ "w", "w" }, 17, 47, { w = "#7a4a1f" })
c:paint({ "w", "w" }, 46, 42, { w = "#7a4a1f" })
local t = c:save(O .. "aseprite/ph/cherry-seed.aseprite", O .. "png/ph/cherry-seed.png")
print(GV.report(t))
