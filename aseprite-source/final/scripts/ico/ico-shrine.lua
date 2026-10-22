local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local posts = c:rect(17, 19, 23, 51):add(c:rect(40, 19, 46, 51))
local tie = c:rect(11, 29, 52, 34)
local top = c:poly({
  {5, 10}, {11, 14}, {19, 16}, {32, 17}, {45, 16}, {53, 14}, {59, 10},
  {57, 18}, {49, 21}, {40, 23}, {32, 23}, {24, 23}, {15, 21}, {7, 18},
})
local feet = c:rect(15, 50, 25, 54):add(c:rect(38, 50, 48, 54))

c:build{
  { "posts", posts, "#d6322b" },
  { "tie",   tie,   "#d6322b" },
  { "top",   top,   "red" },
  { "feet",  feet,  "#5b6470" },
}
c:seam({ {13, 31}, {50, 31} })
c:ground(31.5, 56, 22, 1.5)
local t = c:save(O .. "aseprite/ico/ico-shrine.aseprite", O .. "png/ico/ico-shrine.png")
print(GV.report(t))
