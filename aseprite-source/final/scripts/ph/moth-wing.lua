local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local L = c:poly({ {32, 28}, {22, 21}, {13, 20}, {9, 25}, {11, 34}, {18, 39}, {32, 40} })
L:add(c:ellipse(18, 27, 8, 6))
L:add(c:ellipse(24, 44, 8, 6)):add(c:poly({ {24, 38}, {33, 38}, {33, 54} }))
local R = c:poly({ {32, 28}, {42, 21}, {51, 20}, {55, 25}, {53, 34}, {46, 39}, {32, 40} })
R:add(c:ellipse(46, 27, 8, 6))
R:add(c:ellipse(40, 44, 8, 6)):add(c:poly({ {40, 38}, {31, 38}, {31, 54} }))
local wings = L:copy():add(R)
local p = c:build{
  { "wings", wings, GV.ramp("#3f93b2"), { gloss = { 12, 24 }, stitch = { side = "lit" } } },
}
-- dark centre arch band
local band = c:line({ {14, 34}, {22, 31}, {32, 29}, {42, 31}, {50, 34} }, 3):clip(wings)
c:fill(band, "#256a80")
-- wavy light pattern
c:fill(c:line({ {19, 44}, {22, 42}, {25, 44}, {28, 42}, {30, 44} }, 1):clip(wings), "#c8ecdc")
c:fill(c:line({ {34, 44}, {36, 42}, {39, 44}, {42, 42}, {45, 44} }, 1):clip(wings), "#8fcbd8")
-- wing spots
c:spot(c:rrect(16, 24, 20, 28, 1), "#2f6290", "#5a86b8")
c:spot(c:rrect(44, 24, 48, 28, 1), "#2f6290", "#5a86b8")
-- centre body seam
c:seam({ {32, 30}, {32, 52} })
local t = c:save(O .. "aseprite/ph/moth-wing.aseprite", O .. "png/ph/moth-wing.png")
print(GV.report(t))
