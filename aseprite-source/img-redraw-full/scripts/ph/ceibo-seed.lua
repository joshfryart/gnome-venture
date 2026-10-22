local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- twisted pigtail tip, bent right
local tip = c:poly({ {29, 17}, {30, 12}, {33, 8}, {37, 6}, {38, 8}, {35, 11}, {35, 14}, {36, 17} })
-- cone body
local cone = c:poly({ {32, 13}, {51, 49}, {13, 49} })
cone:add(c:rrect(14, 44, 50, 51, 3))
-- wrap fold diagonal band
local fold = c:line({ {20, 31}, {44, 43} }, 3):clip(cone:copy():shrink(1))
-- seed at the mouth
local seed = c:ellipse(32, 43, 8, 8)
-- sprout
local stem = c:line({ {32, 35}, {32, 30} }, 2)
local leaf = c:poly({ {33, 31}, {35, 27}, {38, 25}, {41, 25}, {40, 28}, {37, 31} })

local p = c:build{
  { "tip",  tip,  "cream", { gloss = false } },
  { "cone", cone, "cream" },
  { "fold", fold, GV.ramp("#dcb06a"), { flat = true } },
  { "seed", seed, GV.ramp("#dcb06a", { shade = "#a5663a" }) },
  { "stem", stem, GV.ramp("#58a03e"), { flat = true } },
  { "leaf", leaf, GV.ramp("#58a03e"), { gloss = false } },
}
-- twist creases on the tip
c:px(33, 10, GV.R.cream.shade); c:px(32, 13, GV.R.cream.shade); c:px(33, 14, GV.R.cream.shade)
c:seam({ {21, 32}, {28, 35} }); c:seam({ {39, 41}, {44, 43} })
c:button(30, 15)
c:px(38, 27, GV.R.leaf and GV.R.leaf.shade or "#4a8a3e")

local t = c:save(O .. "aseprite/ph/ceibo-seed.aseprite", O .. "png/ph/ceibo-seed.png")
print(GV.report(t))
