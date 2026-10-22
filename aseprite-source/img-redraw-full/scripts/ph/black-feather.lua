local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local vane = c:poly({ {18, 46}, {15, 40}, {17, 32}, {24, 24}, {34, 16}, {44, 12}, {50, 10},
                      {47, 19}, {41, 27}, {33, 35}, {25, 42}, {21, 46} })
-- three notched barbs cut into the lower-right edge
vane:cut(c:poly({ {46, 21}, {41, 23}, {44, 25} }))
vane:cut(c:poly({ {39, 29}, {34, 31}, {37, 33} }))
vane:cut(c:poly({ {31, 37}, {26, 39}, {29, 41} }))
local p = c:build{
  { "vane",  vane, GV.ramp("#3e2f66", { shade = "#291d4a", gloss = "#a894dc", rim = "#7b66b4" }) },
  { "quill", c:line({ {14, 51}, {44, 18} }, 3), GV.ramp("#f8eed2"), { gloss = false } },
}
-- sheen streak parallel to the spine on the upper-left half
c:fill(c:line({ {20, 35}, {36, 19} }, 1):clip(p.vane.m), "#7b66b4")
local t = c:save(O .. "aseprite/ph/black-feather.aseprite", O .. "png/ph/black-feather.png")
print(GV.report(t))
