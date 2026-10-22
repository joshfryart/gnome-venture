local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 37, 17, 16)
local leaf = c:poly({ {33, 19}, {35, 14}, {39, 10}, {45, 8}, {44, 13}, {41, 17}, {36, 20} })
c:build{
  { "stalk", c:line({ {31, 22}, {31, 14}, {32, 12} }, 3), "#5e2f1e", { flat = true } },
  { "leaf",  leaf, "#6a9a3a" },
  { "body",  body, "moss" },
}
-- leaf vein
c:fill(c:line({ {36, 18}, {39, 14}, {43, 10} }, 1), "#4a8a3e")
-- cleft from the stalk down the front, bowing left
c:fill(c:line({ {31, 23}, {29, 28}, {28, 34}, {28, 40}, {30, 46}, {33, 50} }, 2), "#4a8a3e")
local t = c:save(O .. "aseprite/ph/pluot.aseprite", O .. "png/ph/pluot.png")
print(GV.report(t))
