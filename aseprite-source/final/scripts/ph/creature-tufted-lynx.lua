local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#dcb06a")
local brn = GV.ramp("#a5663a")
local cream = GV.ramp("#f8eed2")
local tuftR = GV.ramp("#3d2a1c")
local tufts = c:rect(19, 10, 20, 15):add(c:rect(42, 10, 43, 15))
local ears = c:poly({ {17, 27}, {19, 13}, {30, 20} }):add(c:poly({ {32, 20}, {44, 13}, {46, 27} }))
local inner = c:poly({ {20, 23}, {21, 17}, {26, 21} }):add(c:poly({ {37, 21}, {42, 17}, {43, 23} }))
local p = c:build{
  { "tail",  c:ellipse(46, 44, 4, 4), brn },
  { "tufts", tufts, tuftR, { flat = true } },
  { "ears",  ears, tan },
  { "inner", inner, brn, { flat = true, contour = false } },
  { "body",  c:ellipse(31.5, 42, 13, 9.5), tan },
  { "belly", c:ellipse(31.5, 46, 6, 5), cream, { pale = true } },
  { "feet",  c:ellipse(24, 50.5, 4.5, 2.5):add(c:ellipse(39, 50.5, 4.5, 2.5)), brn },
  { "head",  c:ellipse(31.5, 29, 12, 10.5), tan },
  { "muzzle", c:ellipse(31.5, 33, 5.5, 3.5), cream, { pale = true } },
}
-- five spot beans on the body
c:spot(c:rect(20, 39, 22, 40))
c:spot(c:rect(41, 38, 43, 39))
c:spot(c:rect(20, 44, 21, 46))
c:spot(c:rect(42, 44, 43, 46))
c:spot(c:rect(30, 40, 33, 40))
-- face
c:eye(22, 24); c:eye(37, 24)
c:paint({ "nnnn", ".nn." }, 30, 31, { n = "#2a1a10" })
c:paint({ "m....m", ".mmmm." }, 29, 34, { m = "#4a2c1a" })
local t = c:save(O .. "aseprite/ph/creature-tufted-lynx.aseprite", O .. "png/ph/creature-tufted-lynx.png")
print(GV.report(t))
