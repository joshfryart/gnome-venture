local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bulb = c:ellipse(31.5, 38, 15, 13)
bulb:add(c:poly({ {24,30}, {40,30}, {34,21}, {30,21} }))
local base = bulb:copy():clip(c:ellipse(31.5, 55, 17, 9))
local neck = c:rect(30, 12, 33, 24)
local leaf = c:poly({ {33,18}, {36,11}, {41,6}, {47,4}, {45,9}, {40,15}, {36,20} })
local p = c:build{
  { "neck", neck, "#4a8a3e", { flat = true } },
  { "bulb", bulb, "cream" },
  { "base", base, "#dcb06a" },
  { "leaf", leaf, "#58a03e" },
}
local L = "#dcb06a"
c:fill(c:line({ {27,30}, {24,36}, {25,44} }, 1), L)
c:fill(c:line({ {36,30}, {39,36}, {38,44} }, 1), L)
c:fill(c:line({ {31,26}, {31,46} }, 1), L)
local t = c:save(O .. "aseprite/ph/garlic.aseprite", O .. "png/ph/garlic.png")
print(GV.report(t))
