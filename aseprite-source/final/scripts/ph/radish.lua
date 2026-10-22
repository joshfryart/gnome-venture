local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leafR = GV.ramp("#4a8a3e")
local lL = c:poly({ {34,22}, {26,17}, {21,11}, {20,6}, {24,4}, {29,7}, {32,13}, {35,20} })
local lR = c:poly({ {30,22}, {38,17}, {43,11}, {44,6}, {40,4}, {35,7}, {32,13}, {29,20} })
local root = c:ellipse(32, 29, 11, 10)
root:add(c:poly({ {21,29}, {44,29}, {35,52}, {34,56}, {31,56}, {30,52} }))
root:cut(c:rect(0, 0, 63, 19))
local p = c:build{
  { "leafL", lL, leafR },
  { "leafR", lR, GV.ramp("#5a9a40") },
  { "root", root, "petal", { gloss = { 26, 24 } } },
}
c:line({ {32, 20}, {27, 14}, {23, 8} }, 1):each(function(x, y) if lL:shrink(1):has(x, y) then c:px(x, y, "#2f5a2a") end end)
c:line({ {32, 20}, {37, 14}, {41, 8} }, 1):each(function(x, y) if lR:shrink(1):has(x, y) then c:px(x, y, "#2f5a2a") end end)
c:paint({ "hhh" }, 25, 33, { h = "#2a1a10" })
c:paint({ "hhh" }, 37, 41, { h = "#2a1a10" })
local t = c:save(O .. "aseprite/ph/radish.aseprite", O .. "png/ph/radish.png")
print(GV.report(t))
