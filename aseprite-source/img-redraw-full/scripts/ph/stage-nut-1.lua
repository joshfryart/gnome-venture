local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(31.5, 47, 21, 7)
local top = c:ellipse(31.5, 45, 16, 4)
local stem = c:rect(31, 37, 32, 45)
-- leaves: plump pointed teardrops angling up and out from the stem tip
local leafL = c:poly({ {32, 39}, {28, 34}, {23, 31}, {20, 30}, {21, 34}, {25, 38}, {30, 40} })
local leafR = c:poly({ {32, 38}, {36, 33}, {41, 29}, {45, 28}, {44, 32}, {40, 36}, {34, 39} })
local p = c:build{
  { "mound", mound, GV.ramp("#8c4a1a") },
  { "top", top, GV.ramp("#a5663a"), { stitch = false } },
  { "stem", stem, GV.ramp("#c4925f"), { flat = true } },
  { "leafL", leafL, GV.ramp("#58a03e") },
  { "leafR", leafR, GV.ramp("#7ab55c") },
}
-- leaf midribs
c:line({ {30, 38}, {26, 35}, {22, 32} }, 1)
c:fill(c:line({ {30, 38}, {26, 35}, {22, 32} }, 1):clip(p.leafL.m), "#2f5a2a")
c:fill(c:line({ {34, 37}, {39, 33}, {43, 30} }, 1):clip(p.leafR.m), "#4a8a3e")
-- a couple of soil crumbs on the mound top
c:px(22, 44, "#6b3a1c"); c:px(41, 46, "#6b3a1c"); c:px(26, 47, "#6b3a1c")
c:ground(31.5, 54, 16, 1.5)
local t = c:save(O .. "aseprite/ph/stage-nut-1.aseprite", O .. "png/ph/stage-nut-1.png")
print(GV.report(t))
