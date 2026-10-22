local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local trunk = c:rrect(25, 30, 39, 53, 3)
trunk:add(c:poly({ {21, 54}, {25, 47}, {39, 47}, {43, 54} }))
trunk:add(c:rect(22, 51, 42, 53))
local back = c:ellipse(32, 23, 20, 15)
local left = c:ellipse(19.5, 30, 9, 8)
local right = c:ellipse(44, 21, 8, 8)

local p = c:build{
  { "trunk", trunk, "wood" },
  { "crown", back, GV.ramp("#6a9a3a") },
  { "left", left, GV.ramp("#7ab55c") },
  { "right", right, GV.ramp("#4a8a3e") },
}
-- heart-shaped hollow
c:paint({
  ".hh.hh.",
  "hhhhhhh",
  "hhhhhhh",
  "hhhhhhh",
  ".hhhhh.",
  "..hhh..",
  "..lhl..",
  "...l...",
}, 29, 40, { h = "#2a1a10", l = "#5e2f1e" })
-- bark lines
c:px(27, 46, GV.R.wood.shade); c:px(27, 47, GV.R.wood.shade)
c:px(37, 39, GV.R.wood.shade); c:px(37, 40, GV.R.wood.shade)
-- leaf creases
c:paint({ "c....c", ".cccc." }, 15, 28, { c = "#2f5a2a" })
c:paint({ "c...c", ".ccc." }, 30, 30, { c = "#2f5a2a" })
c:paint({ "c...c", ".ccc." }, 41, 23, { c = "#2f5a2a" })
c:ground(32, 55, 13, 1.5)

local t = c:save(O .. "aseprite/ph/hollowheart-tree.aseprite", O .. "png/ph/hollowheart-tree.png")
print(GV.report(t))
