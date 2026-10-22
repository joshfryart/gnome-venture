local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local stem = c:rect(31, 7, 32, 14)
local leaf = c:poly({ {32,10}, {36,5}, {42,4}, {40,8}, {34,11} })
local bulb = c:ellipse(32, 19, 8, 7)
local cone = c:poly({ {12,24}, {53,24}, {34,57}, {31,57} })
cone:add(c:rrect(30, 50, 34, 57, 1))
local rimm = c:ellipse(32.5, 24, 20.5, 4)
local whole = cone:copy(); whole:add(rimm)

c:build{
  { "stem", stem, "moss", { flat = true } },
  { "leaf", leaf, "moss" },
  { "bulb", bulb, GV.ramp("#dcb06a") },
  { "cone", cone, GV.ramp("#f1ece0"), { light = whole } },
  { "rim",  rimm, GV.ramp("#f4f0e0"), { light = whole, gloss = false } },
}
-- spiral fold band across the front, clipped to the cone
local fold = c:line({ {15,30}, {47,40} }, 3):clip(cone)
c:fill(fold, "#d6c9b6")
local fold2 = c:line({ {22,43}, {41,48} }, 2):clip(cone)
c:fill(fold2, "#d6c9b6")
-- twist wrap crossing near the top of the cone
c:fill(c:line({ {26,27}, {38,31} }, 2):clip(cone), "#c4955a")
c:seam({ {15,29}, {47,39} })
-- seed hole showing inside the rim
c:fill(c:ellipse(32.5, 23.5, 15, 1.5):cut(bulb), "#b8a58a")

local t = c:save(O .. "aseprite/ph/hyacinth-seed.aseprite", O .. "png/ph/hyacinth-seed.png")
print(GV.report(t))
