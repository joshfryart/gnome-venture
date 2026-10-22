local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- spoon: handle slanting up-right, bowl at the tip
local handle = c:line({ {34, 34}, {47, 20} }, 4)
local sbowl = c:poly({ {45, 17}, {48, 11}, {53, 9}, {57, 11}, {56, 16}, {51, 21}, {47, 21} })
-- porridge mound (arch)
local mound = c:ellipse(31, 37, 18, 13):cut(c:rect(0, 38, 63, 63))
-- bowl half-round
local bowl = c:ellipse(31.5, 38, 24.5, 18):cut(c:rect(0, 0, 63, 37))
bowl:clip(c:rect(0, 0, 63, 55))
local rim = c:rrect(7, 34, 56, 40, 3)

local p = c:build{
  { "mound", mound, "#f8eed2" },
  { "butter", c:rrect(24, 21, 34, 28, 2), "#f2cf4a" },
  { "handle", handle, "#c4925f" },
  { "sbowl", sbowl, "#a5663a" },
  { "bowl", bowl, "#3f93b2" },
  { "rim", rim, "#dcb06a" },
}
c:seam({ {10, 37}, {53, 37} })
c:button(46, 45)
local t = c:save(O .. "aseprite/ico/ico-porridge.aseprite", O .. "png/ico/ico-porridge.png")
print(GV.report(t))
