local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local post = c:rect(29, 13, 35, 54)
local cap = c:rrect(27, 10, 37, 14, 1)
local up = c:poly({ {12, 16}, {46, 16}, {54, 23}, {46, 31}, {12, 31} })
local lo = c:poly({ {52, 35}, {18, 35}, {10, 42}, {18, 49}, {52, 49} })

c:build{
  { "post", post, "wood" },
  { "cap",  cap,  "#8a4f2a" },
  { "up",   up,   "#a8582f" },
  { "lo",   lo,   "#d9a660" },
}
c:fill(c:rect(31, 22, 32, 23), "#5e2f1e")
c:fill(c:rect(31, 41, 32, 42), "#5e2f1e")
c:ground(32, 56, 9, 1.5)
local t = c:save(O .. "aseprite/ico/ico-signpost.aseprite", O .. "png/ico/ico-signpost.png")
print(GV.report(t))
