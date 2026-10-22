local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- handle: diagonal wood shaft to lower right, rounded end
local handle = c:line({ {31, 18}, {47, 51} }, 6):add(c:ellipse(47.5, 51.5, 3, 3))

-- head: curved crescent, thick in middle, tapering to down-pointing tips
local head = c:ellipse(31.5, 31, 24, 19):cut(c:ellipse(31.5, 35, 21, 15))
head:cut(c:rect(0, 28, 63, 63))
head:add(c:poly({ {8, 22}, {13, 22}, {9, 30} }))
head:add(c:poly({ {51, 22}, {56, 22}, {55, 30} }))

local collar = c:rrect(28, 19, 35, 23, 1)

c:build{
  { "handle", handle, GV.ramp("#b07a45", { rim = "#d9a660" }) },
  { "head", head, "stone", { gloss = { 20, 16 } } },
  { "collar", collar, GV.ramp("#c9c5bc"), { flat = true } },
}
c:paint({ "hh", "hh" }, 10, 24, { h = "#c9c5bc" })
c:paint({ "hh", "hh" }, 52, 24, { h = "#c9c5bc" })
c:button(30, 19)

local t = c:save(O .. "aseprite/ph/prospector-s-pick.aseprite", O .. "png/ph/prospector-s-pick.png")
print(GV.report(t))
