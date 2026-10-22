local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local root = c:ellipse(32, 25, 11, 7):add(c:poly({ {21,25}, {44,25}, {38,42}, {34,52}, {32,57}, {30,52}, {26,42} }))
local lleaf = c:ellipse(25.5, 14, 4, 7.5)
local rleaf = c:ellipse(38.5, 14, 4, 7.5)
local lstem = c:line({ {30,20}, {28,15} }, 2)
local leaf = GV.ramp("#58a03e")
local p = c:build{
  { "lleaf", c:poly({ {32,21}, {26,16}, {21,11}, {24,5}, {28,7}, {31,13}, {33,20} }), leaf },
  { "rleaf", c:poly({ {31,21}, {33,13}, {36,7}, {40,5}, {43,11}, {38,16}, {32,21} }), leaf },
  { "root", root, GV.ramp("#b0bc66") },
}
c:fill(c:line({ {25,31}, {31,31} }, 2):clip(root:shrink(1)), "#58a03e")
c:fill(c:line({ {34,39}, {38,39} }, 2):clip(root:shrink(1)), "#58a03e")
c:fill(c:line({ {29,46}, {32,46} }, 1):clip(root:shrink(1)), "#58a03e")
local t = c:save(O .. "aseprite/ph/ginseng.aseprite", O .. "png/ph/ginseng.png")
print(GV.report(t))
