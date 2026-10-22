-- ph/garden-hoe
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local stoneR = GV.ramp("#968f96")
-- handle: diagonal wooden shaft
local handle = c:line({ {17,50}, {37,14} }, 5)
local butt = c:ellipse(17, 51, 3.5, 3.5)
-- blade: flat trapezoid set sideways at the top
local blade = c:poly({ {33,10}, {52,10}, {50,22}, {31,22} })
c:build{
  { "handle", handle, "wood", { gloss = { 26, 31 } } },
  { "butt",   butt, GV.ramp("#8a4f2a"), { gloss = false } },
  { "blade",  blade, stoneR },
  { "collar", c:rrect(34, 12, 39, 17, 1), GV.ramp("#5b6470"), { gloss = false } },
}
-- sharpened lower edge
c:fill(c:rect(32, 19, 50, 20):clip(blade), "#c9c5bc")
-- wood grain
c:fill(c:line({ {21,46}, {33,23} }, 1), "#8a4f2a")
c:button(35, 13)

local t = c:save(O .. "aseprite/ph/garden-hoe.aseprite", O .. "png/ph/garden-hoe.png")
print(GV.report(t))
