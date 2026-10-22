local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local grey = GV.ramp("#968f96")
local earL = c:poly({ {9, 7}, {29, 22}, {13, 34} })
local earR = c:poly({ {55, 7}, {35, 22}, {51, 34} })
local head = c:ellipse(31.5, 30, 20, 10)
head:add(c:poly({ {12, 30}, {52, 30}, {41, 57}, {23, 57} }))
local muzzle = c:poly({ {27, 38}, {37, 38}, {41, 55}, {23, 55} })
muzzle:add(c:ellipse(31.5, 52, 8.5, 4))
muzzle:clip(head)

c:build{
  { "earL", earL, grey, { gloss = false } },
  { "earR", earR, grey, { gloss = false } },
}
c:fill(c:poly({ {13, 13}, {25, 22}, {15, 29} }), "#6a6070")
c:fill(c:poly({ {51, 13}, {39, 22}, {49, 29} }), "#6a6070")
c:build{
  { "head",   head,   grey, { gloss = { 18, 25 } } },
  { "muzzle", muzzle, GV.ramp("#f8eed2"), { pale = true, gloss = false } },
}
-- brow notch: darker forehead stripe
c:paint({ "d.d", "ddd", ".d." }, 31, 23, { d = "#6a6070" })
-- nose
c:fill(c:ellipse(31.5, 51, 4.5, 3), "#2a1a10")
c:px(29, 49, "#5e4a5a"); c:px(30, 49, "#5e4a5a")
-- orange eye rings then eyes
c:fill(c:rrect(19, 29, 25, 35, 2), "#e8892a")
c:fill(c:rrect(38, 29, 44, 35, 2), "#e8892a")
c:eye(20, 30); c:eye(39, 30)
local t = c:save(O .. "aseprite/ico/ico-wolf.aseprite", O .. "png/ico/ico-wolf.png")
print(GV.report(t))
