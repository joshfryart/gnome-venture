local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local root = c:poly({ {21, 22}, {23, 20}, {42, 20}, {44, 22}, {35, 54}, {34, 57}, {31, 57}, {30, 54} })
local leafR = GV.ramp("#58a03e")
local p = c:build{
  { "root", root, "#f08a24", { gloss = { 25, 25 } } },
  { "leafl", c:poly({ {32, 21}, {24, 9}, {25, 6}, {28, 7}, {33, 15}, {33, 21} }), leafR, { gloss = false } },
  { "leafr", c:poly({ {32, 21}, {32, 15}, {37, 7}, {40, 6}, {41, 9}, {34, 21} }), leafR, { gloss = false } },
}
-- root rings
c:line({ {25, 31}, {30, 31} }, 1)
c:paint({ "rrrrrr", ".rrrr." }, 25, 30, { r = "#e0501f" })
c:paint({ "rrrrr", ".rrr." }, 35, 39, { r = "#e0501f" })
c:paint({ "rrrr", ".rr." }, 29, 47, { r = "#e0501f" })
-- leaf veins
c:px(28, 11, "#4a8a3e"); c:px(29, 13, "#4a8a3e"); c:px(30, 15, "#4a8a3e")
c:px(36, 11, "#4a8a3e"); c:px(35, 13, "#4a8a3e"); c:px(34, 15, "#4a8a3e")

local t = c:save(O .. "aseprite/ph/carrot.aseprite", O .. "png/ph/carrot.png")
print(GV.report(t))
