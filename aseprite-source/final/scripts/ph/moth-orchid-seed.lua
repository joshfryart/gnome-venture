local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cone = c:poly({ {13, 23}, {52, 23}, {34, 51}, {31, 51} })
local tint = c:poly({ {40, 23}, {52, 23}, {34, 51}, {33, 51} }):clip(cone)
local rim = c:rrect(11, 20, 53, 25, 2)
local twist = c:poly({ {29, 49}, {36, 49}, {34, 52}, {36, 55}, {29, 55}, {31, 52} })

local p = c:build{
  { "stem",  c:rect(31, 7, 32, 10), "#2f5a2a", { flat = true } },
  { "leaf",  c:ellipse(36.5, 8.5, 3.5, 1.5), "#4a8a3e", { flat = true } },
  { "seed",  c:ellipse(31.5, 15.5, 7.5, 7), "water" },
  { "cone",  cone, "#f1ece0", { pale = true } },
  { "tint",  tint, "#d9c9a0", { light = cone, rim = false, gloss = false, contour = false } },
  { "twist", twist, "#b0955a" },
  { "rim",   rim, "#d9a660" },
}
-- spiral fold
local fold = c:line({ {17, 27}, {34, 48} }, 2):clip(cone)
c:fill(fold, "#d9a660")
c:seam({ {18, 26}, {35, 47} })
c:ground(32, 57, 9, 1.5)
local t = c:save(O .. "aseprite/ph/moth-orchid-seed.aseprite", O .. "png/ph/moth-orchid-seed.png")
print(GV.report(t))
