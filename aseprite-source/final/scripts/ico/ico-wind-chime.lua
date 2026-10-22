local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local ring = c:ellipse(32, 10, 5, 5):cut(c:ellipse(32, 10, 2, 2))
ring:add(c:rect(31, 14, 33, 17))
local strings = c:rect(13, 24, 15, 31):add(c:rect(31, 24, 33, 32)):add(c:rect(49, 24, 51, 35))
strings:add(c:rect(31, 46, 33, 48))

local p = c:build{
  { "loop", ring, "#968f96", { gloss = false } },
  { "strings", strings, "#968f96", { flat = true } },
  { "bar", c:rrect(9, 16, 55, 24, 4), "#c4925f" },
  { "long", c:rrect(10, 30, 18, 54, 2), "#dcb06a" },
  { "mid", c:rrect(28, 31, 36, 46, 2), "#f2cf4a" },
  { "short", c:rrect(46, 34, 54, 47, 2), "#dcb06a" },
  { "clapper", c:ellipse(32, 52, 4, 4), "#a5663a" },
}
-- tube end rings
c:fill(c:rect(11, 33, 17, 33), GV.ramp("#dcb06a").shade)
c:fill(c:rect(29, 34, 35, 34), GV.ramp("#f2cf4a").shade)
c:fill(c:rect(47, 37, 53, 37), GV.ramp("#dcb06a").shade)

local t = c:save(O .. "aseprite/ico/ico-wind-chime.aseprite", O .. "png/ico/ico-wind-chime.png")
print(GV.report(t))
