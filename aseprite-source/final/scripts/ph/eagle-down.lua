local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local vane = c:poly({ {17, 53}, {12, 44}, {11, 34}, {16, 24}, {26, 15}, {38, 10}, {50, 8}, {50, 18}, {48, 28}, {42, 38}, {32, 47}, {22, 53} })
-- soft notches in the vane edge (split barbs)
vane:cut(c:poly({ {50, 22}, {44, 26}, {50, 24} }))
vane:cut(c:poly({ {11, 40}, {18, 38}, {11, 42} }))
local quill = c:line({ {15, 55}, {44, 17} }, 3)
local p = c:build{
  { "vane", vane, "gold", { gloss = { 21, 23 } } },
  { "quill", quill, GV.ramp("#b8661a"), { flat = true } },
  { "tip", c:line({ {15, 55}, {13, 56} }, 2), GV.ramp("#d0862a"), { flat = true } },
}
local B = "#b8661a"
c:fill(c:line({ {28, 39}, {35, 37} }, 2), B)
c:fill(c:line({ {34, 31}, {41, 29} }, 2), B)
c:fill(c:line({ {22, 46}, {28, 45} }, 2), B)
c:fill(c:line({ {40, 23}, {45, 21} }, 2), B)
local t = c:save(O .. "aseprite/ph/eagle-down.aseprite", O .. "png/ph/eagle-down.png")
print(GV.report(t))
