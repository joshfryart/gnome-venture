local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local rod = c:line({ {10, 53}, {44, 11} }, 4)
local tip = c:line({ {42, 13}, {48, 6} }, 2)
local line = c:line({ {48, 7}, {52, 10}, {55, 15}, {56, 21}, {55, 27}, {53, 32} }, 1)
local bob = c:ellipse(52.5, 36.5, 3.5, 3.5)
local reel = c:ellipse(21, 44, 5, 5)

local p = c:build{
  { "line", line, GV.ramp("#f1ece0"), { flat = true } },
  { "rod", rod, "wood" },
  { "tip", tip, "wood", { flat = true } },
  { "bob", bob, "red" },
  { "reel", reel, GV.ramp("#a8582f") },
}
c:fill(c:rect(20, 43, 21, 44), "#e8a317")
-- thread wrap at the handle
c:seam({ {12, 49}, {16, 53} }, { free = true })
c:ground(30, 55, 18, 1.5)
local t = c:save(O .. "aseprite/ph/willow-fishing-rod.aseprite", O .. "png/ph/willow-fishing-rod.png")
print(GV.report(t))
