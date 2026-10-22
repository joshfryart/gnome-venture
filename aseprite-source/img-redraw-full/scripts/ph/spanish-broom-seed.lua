local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local jar = c:rrect(14, 22, 50, 57, 8)
local neck = c:rect(23, 14, 41, 24)
local cork = c:rrect(21, 6, 43, 16, 2)
local seed = c:ellipse(32, 42, 9, 9)
local stem = c:rect(31, 28, 33, 34)
local leaf = c:ellipse(38.5, 28, 4.5, 2.5)

c:build{
  { "jar",  jar,  GV.ramp("#c8ecdc"), { pale = true, gloss = false, light = jar:copy():add(neck) } },
  { "neck", neck, GV.ramp("#c8ecdc"), { pale = true, gloss = false } },
  { "cork", cork, "wood" },
  { "seed", seed, "#dcb06a" },
  { "stem", stem, "#2e5a2c", { flat = true } },
  { "leaf", leaf, "#58a03e", { flat = true } },
}
-- glass inner edges
c:fill(c:rect(18, 30, 18, 50), "#8fcbd8"); c:fill(c:rect(46, 30, 46, 50), "#8fcbd8")
-- shoulder line
c:fill(c:rect(22, 25, 42, 25), "#8fcbd8")
-- glint streak
c:fill(c:rect(20, 29, 21, 41), "#fff3c8"); c:fill(c:rect(20, 44, 21, 46), "#fff3c8")
-- cork flecks
c:px(26, 9, "#8a4f2a"); c:px(33, 11, "#8a4f2a"); c:px(38, 8, "#8a4f2a"); c:px(29, 13, "#8a4f2a")
-- thread neck tie
c:seam({ {23, 18}, {41, 18} })

local t = c:save(O .. "aseprite/ph/spanish-broom-seed.aseprite", O .. "png/ph/spanish-broom-seed.png")
print(GV.report(t))
