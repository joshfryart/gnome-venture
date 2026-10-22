local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local fin = GV.ramp("#d9611f")
local tail = c:poly({ { 40, 33 }, { 57, 16 }, { 53, 33 }, { 57, 49 } })
local p = c:build{
  { "tail", tail, fin },
  { "fin", c:poly({ { 17, 23 }, { 30, 9 }, { 38, 23 } }), fin, { gloss = false } },
  { "body", c:ellipse(27.5, 33, 20, 14), GV.ramp("#f08a24") },
}
-- tail rays
c:line({ { 47, 28 }, { 52, 24 } }, 1)
c:fill(c:line({ { 47, 28 }, { 52, 23 } }, 1), "#b8452f")
c:fill(c:line({ { 47, 38 }, { 52, 43 } }, 1), "#b8452f")
-- gill curve
c:fill(c:line({ { 21, 24 }, { 23, 29 }, { 23, 36 }, { 21, 41 } }, 2), "#c0501a")
-- scales (beans)
c:paint({ "ss.", ".ss" }, 30, 30, { s = "#d9611f" })
c:paint({ "ss.", ".ss" }, 36, 36, { s = "#d9611f" })
c:paint({ "ss.", ".ss" }, 31, 40, { s = "#d9611f" })
c:eye(12, 28)
-- smile
c:paint({ "m..", ".mm" }, 9, 37, { m = "#6b1b2c" })
local t = c:save(O .. "aseprite/ico/ico-fish.aseprite", O .. "png/ico/ico-fish.png")
print(GV.report(t))
