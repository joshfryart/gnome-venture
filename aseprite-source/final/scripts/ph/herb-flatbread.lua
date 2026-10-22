local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- dome loaf: half ellipse top + rounded flat base
local dome = c:ellipse(31.5, 42, 22, 20):cut(c:rect(0, 43, 63, 63))
dome:add(c:rrect(10, 36, 53, 50, 7))
local crust = c:rrect(10, 44, 53, 50, 6)
crust:clip(dome); crust:cut(c:rect(0, 0, 63, 43))
local p = c:build{
  { "dome", dome, GV.ramp("#dcb06a"), { light = dome } },
  { "crust", crust, GV.ramp("#b07a45"), { light = dome, gloss = false } },
}
-- herb sprigs
local G, D = "#7ab55c", "#4a8a3e"
c:fill(c:line({ {15, 37}, {19, 32}, {23, 30}, {27, 32} }, 2), G)
c:fill(c:line({ {31, 29}, {35, 25}, {39, 26}, {42, 28} }, 2), G)
c:fill(c:line({ {39, 40}, {43, 36}, {47, 37} }, 2), G)
-- tiny leaves on sprigs
c:fill(c:ellipse(20.5, 35, 1.5, 1), G)
c:fill(c:ellipse(36.5, 29, 1.5, 1), G)
c:fill(c:ellipse(44.5, 40, 1.5, 1), G)
c:px(15, 38, D); c:px(16, 38, D); c:px(27, 33, D); c:px(28, 33, D)
c:px(31, 30, D); c:px(32, 30, D); c:px(42, 29, D); c:px(43, 29, D)
c:px(39, 41, D); c:px(40, 41, D); c:px(47, 38, D); c:px(48, 38, D)
-- loose flecks
c:px(26, 39, D); c:px(33, 36, D); c:px(22, 42, G); c:px(48, 32, G)
local t = c:save(O .. "aseprite/ph/herb-flatbread.aseprite", O .. "png/ph/herb-flatbread.png")
print(GV.report(t))
