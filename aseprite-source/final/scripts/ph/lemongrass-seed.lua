local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bL = c:poly({ {28, 27}, {32, 27}, {24, 13}, {21, 10}, {22, 14} })
local bM = c:poly({ {30, 27}, {35, 27}, {34, 12}, {32, 9}, {30, 12} })
local bR = c:poly({ {32, 27}, {37, 27}, {42, 15}, {44, 11}, {40, 13} })
local sack = c:ellipse(32, 41, 17, 13):add(c:ellipse(32, 45, 18, 9))
local gather = c:rrect(25, 23, 39, 31, 3)
local twine = c:rect(24, 28, 40, 31)
local patch = c:rrect(22, 37, 37, 47, 2)
local p = c:build{
  { "bL", bL, "#a4b86a" },
  { "bR", bR, "#a4b86a" },
  { "bM", bM, "#7ab55c" },
  { "sack", sack, "#c9a96e", { stitch = true } },
  { "gather", gather, "#c9a96e" },
  { "twine", twine, "#8a4f2a", { gloss = false } },
  { "patch", patch, "#e8d3a2", { gloss = false } },
}
c:fill(c:rect(36, 32, 37, 35), "#8a4f2a")
c:fill(c:rect(40, 32, 41, 34), "#8a4f2a")
c:button(37, 27)
c:spot(c:rrect(28, 40, 31, 43, 1), "#f5cf6a", "#fff1c8")
c:seam({ {32, 49}, {32, 52} })
c:seam({ {42, 34}, {42, 50} })
local t = c:save(O .. "aseprite/ph/lemongrass-seed.aseprite", O .. "png/ph/lemongrass-seed.png")
print(GV.report(t))
