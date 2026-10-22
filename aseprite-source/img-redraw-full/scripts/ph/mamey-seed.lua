local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local sack = c:ellipse(31.5, 40, 19, 15)
sack:add(c:poly({ { 24, 26 }, { 40, 26 }, { 46, 34 }, { 18, 34 } }))
local ears = c:poly({ { 21, 27 }, { 23, 13 }, { 32, 27 } })
ears:add(c:poly({ { 32, 27 }, { 41, 13 }, { 44, 27 } }))
local stem = c:rect(31, 15, 32, 24)
local leaf = c:ellipse(37, 13, 4, 2.5)
local win  = c:ellipse(31.5, 43, 7, 7)
local tie  = c:rrect(22, 25, 41, 28, 1)
local loops = c:ellipse(25, 30, 3, 2.5):cut(c:rect(24, 30, 26, 30))
loops:add(c:ellipse(38, 30, 3, 2.5):cut(c:rect(37, 30, 39, 30)))
loops:add(c:line({ { 30, 28 }, { 28, 34 } }, 2))
loops:add(c:line({ { 33, 28 }, { 35, 34 } }, 2))

c:build{
  { "stem", stem, "#2e5a2c", { flat = true } },
  { "leaf", leaf, "#58a03e", { gloss = { 35, 12 } } },
  { "ears", ears, "skin", { gloss = false } },
  { "sack", sack, "skin" },
  { "win", win, "gold", { gloss = { 28, 40 } } },
  { "tie", tie, "#a8582f", { gloss = false } },
  { "loops", loops, "#a8582f", { flat = true } },
}
c:stitch(sack:copy():cut(c:rect(0, 0, 63, 33)), { side = "lit" })
c:px(21, 36, GV.R.skin.shade); c:px(20, 38, GV.R.skin.shade); c:px(20, 39, GV.R.skin.shade)
c:px(19, 41, GV.R.skin.shade); c:px(19, 42, GV.R.skin.shade)
c:px(43, 37, GV.R.skin.shade); c:px(44, 39, GV.R.skin.shade); c:px(44, 40, GV.R.skin.shade)
c:ground(31.5, 56, 15, 1.5)
local t = c:save(O .. "aseprite/ph/mamey-seed.aseprite", O .. "png/ph/mamey-seed.png")
print(GV.report(t))
