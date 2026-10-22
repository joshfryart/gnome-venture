local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 41, 18, 15):cut(c:rect(0, 56, 63, 63))
body:add(c:rrect(18, 50, 45, 55, 3))
local collar = c:rrect(20, 24, 43, 29, 2)
local lid = c:ellipse(31.5, 22, 14, 9):cut(c:rect(0, 22, 63, 63))
lid:add(c:rrect(17, 19, 46, 22, 2))
local knob = c:ellipse(31.5, 11, 3.5, 3.5)
local pad = c:ellipse(31.5, 42, 6, 8)
c:build{
  { "body", body, GV.ramp("#b0bc66", { deep = "#2f5a2a" }) },
  { "collar", collar, "#a4b86a" },
  { "lid", lid, "#7ab55c" },
  { "knob", knob, "#6a9a3a" },
  { "pad", pad, "#58a03e", { gloss = { 29, 37 } } },
}
-- small nub pad on the big pad
c:paint({ "ss", "ss" }, 29, 39, { s = "#f1ece0" })
c:paint({ "ss", "ss" }, 33, 44, { s = "#f1ece0" })
c:spot(c:ellipse(46, 33, 1.5, 2), "#4a8a3e")
c:seam({ { 21, 26 }, { 42, 26 } })
c:button(30, 25)
c:ground(31.5, 57, 15, 1.5)
local t = c:save(O .. "aseprite/ph/nopal-seed.aseprite", O .. "png/ph/nopal-seed.png")
print(GV.report(t))
