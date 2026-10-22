local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local log = c:rrect(11, 22, 50, 45, 11)
local nub = c:rrect(9, 40, 15, 47, 2)
local face = c:ellipse(46, 33.5, 7.5, 11.5)
c:build{
  { "nub", nub, GV.ramp("#a8582f"), { gloss = false } },
  { "log", log, GV.ramp("#8c4a1a"), { gloss = { 19, 27 } } },
  { "face", face, GV.ramp("#dcb06a"), { gloss = { 42, 26 } } },
}
-- bark grooves
c:fill(c:line({ {17,29}, {34,29} }, 2), "#5e2f1e")
c:fill(c:line({ {15,38}, {36,38} }, 2), "#5e2f1e")
c:fill(c:line({ {22,34}, {30,34} }, 1), "#5e2f1e")
-- growth rings
local ring = c:ellipse(46, 33.5, 4.5, 7.5):cut(c:ellipse(46, 33.5, 2.5, 5.5))
c:fill(ring, "#a5663a")
c:fill(c:ellipse(46, 33.5, 0.6, 1.5), "#a5663a")
c:ground(31, 49, 18, 1.5)
local t = c:save(O .. "aseprite/ph/mangrove-root.aseprite", O .. "png/ph/mangrove-root.png")
print(GV.report(t))
