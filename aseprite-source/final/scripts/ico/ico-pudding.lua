local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local plate = c:ellipse(31.5, 47, 25, 5)
-- dome: rounded top, slightly flared base
local dome = c:ellipse(31.5, 30, 18.5, 16):cut(c:rect(0, 31, 63, 63))
dome:add(c:poly({ {13, 30}, {51, 30}, {53, 46}, {11, 46} }))
-- caramel cap with scalloped drips
local cap = c:ellipse(31.5, 30, 18.5, 16):cut(c:rect(0, 28, 63, 63))
cap:add(c:rect(13, 24, 50, 29))
cap:add(c:ellipse(16, 31, 3, 3))
cap:add(c:ellipse(22.5, 33, 3.5, 4))
cap:add(c:ellipse(30, 31, 3, 3))
cap:add(c:ellipse(37.5, 32, 3, 3))
cap:add(c:ellipse(44.5, 34, 3.5, 4))
cap:add(c:ellipse(49, 31, 2.5, 3))
cap:clip(dome)

local p = c:build{
  { "plate", plate, "#968f96" },
  { "dome", dome, "#f0c860" },
  { "cap", cap, "#8c4a1a" },
}
local t = c:save(O .. "aseprite/ico/ico-pudding.aseprite", O .. "png/ico/ico-pudding.png")
print(GV.report(t))
