local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local centre = c:poly({ {32,6}, {44,20}, {39,55}, {25,55}, {20,20} })
local left = c:poly({ {11,55}, {20,35}, {30,55} })
local right = c:poly({ {34,55}, {46,37}, {55,55} })
local blue = GV.ramp("#a9d6ea")
local purp = GV.ramp("#a894dc")
local p = c:build{
  { "centre", centre, blue, { gloss = { 27, 18 } } },
  { "left", left, purp },
  { "right", right, purp },
}
local vis = centre:copy():cut(left):cut(right)
local fac = c:line({ {21,21}, {32,29}, {43,21} }, 2):add(c:line({ {32,29}, {32,54} }, 2)):clip(vis:shrink(1))
c:fill(fac, "#3f8fb0")
c:px(29, 14, blue.dot)
c:ground(32.5, 56, 22, 1.5)
local t = c:save(O .. "aseprite/ph/geode.aseprite", O .. "png/ph/geode.png")
print(GV.report(t))
