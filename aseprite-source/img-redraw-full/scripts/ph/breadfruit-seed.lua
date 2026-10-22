local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leafM = c:ellipse(39, 15, 6, 3):cut(c:rect(0, 0, 63, 0))
local p = c:build{
  { "leaf", c:poly({ {34, 21}, {37, 13}, {44, 9}, {44, 11}, {41, 18} }), "#58a03e" },
  { "seed", c:ellipse(31.5, 26, 8, 8), "moss" },
  { "cone", c:poly({ {14, 30}, {50, 30}, {33, 52}, {31, 52} }), "cream" },
  { "tail", c:line({ {32, 50}, {34, 53}, {37, 55} }, 3), "#dcb06a" },
  { "rim",  c:rrect(13, 28, 50, 32, 1), "#dcb06a" },
}
c:seam({ {22, 34}, {31, 49} })
c:px(36, 53, "#a8582f"); c:px(33, 51, "#a8582f")
c:paint({ "..s", ".s.", "s.." }, 36, 15, { s = "#2f5a2a" })
local t = c:save(O .. "aseprite/ph/breadfruit-seed.aseprite", O .. "png/ph/breadfruit-seed.png")
print(GV.report(t))
