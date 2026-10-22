local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#dcb06a")
local paper = GV.ramp("#f1ece0")
-- seed ball behind the rim
local seed = c:ellipse(32, 20, 7.5, 7.5)
local leaf = c:poly({ {34, 13}, {38, 9}, {44, 8}, {42, 12}, {36, 14} })
local stem = c:rect(31, 10, 32, 13)
-- cone body
local cone = c:poly({ {14, 25}, {51, 25}, {37, 51}, {28, 51} })
-- ruffled rim band
local band = c:rrect(12, 21, 52, 28, 3)
for x = 13, 49, 6 do band:add(c:ellipse(x + 1.5, 21, 2.5, 2)) end
-- twisted tip curl
local tip = c:poly({ {28, 48}, {37, 48}, {34, 53}, {31, 53} })
tip:add(c:line({ {32, 53}, {30, 55}, {26, 55} }, 2))
local p = c:build{
  { "leaf", leaf, GV.ramp("#58a03e"), { flat = true } },
  { "stem", stem, GV.ramp("#2e5a2c"), { flat = true } },
  { "seed", seed, GV.ramp("#f08a24") },
  { "cone", cone, paper, { pale = true } },
  { "tip", tip, tan, { flat = true } },
  { "band", band, tan },
}
-- diagonal fold line on cone
local fold = c:line({ {21, 30}, {34, 47} }, 2):clip(cone)
c:fill(fold, tan.base)
c:fill(c:line({ {22, 30}, {35, 47} }, 1):clip(cone):cut(fold:shift(0,0)), tan.shade)
c:seam({ {15, 25}, {50, 25} })
-- label dab
c:spot(c:ellipse(41.5, 34.5, 2, 2), "#f08a24", "#ffc27a")
-- zinnia ridge lines on seed
c:paint({ "r.r.r" }, 30, 13, { r = "#e0501f" })
local t = c:save(O .. "aseprite/ph/zinnia-seed.aseprite", O .. "png/ph/zinnia-seed.png")
print(GV.report(t))
