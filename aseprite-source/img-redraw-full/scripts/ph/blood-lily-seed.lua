-- ph/blood-lily-seed (paper cone twist)
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local paper = GV.ramp("#f1ece0")
local tan = GV.ramp("#dcb06a")
local bulbR = GV.ramp("#3f93b2", { shade = "#256a80" })
local leafR = GV.ramp("#58a03e")

-- leaf angled up-right, on a short stem
local leaf = c:poly({ {33, 15}, {37, 9}, {43, 7}, {46, 8}, {43, 13}, {37, 17} })
local stem = c:rect(31, 12, 32, 18)
local bulb = c:ellipse(31.5, 23, 9, 8.5)
local cone = c:poly({ {13, 27}, {52, 27}, {34, 56}, {31, 56} })
local rim = c:rrect(12, 24, 52, 30, 2)

c:build{
  { "stem", stem, "#2e5a2c", { flat = true } },
  { "leaf", leaf, leafR, { gloss = false } },
  { "bulb", bulb, bulbR },
  { "cone", cone, paper, { gloss = { 18, 33 } } },
  { "rim",  rim,  tan, { gloss = false } },
}
-- leaf midrib
c:fill(c:line({ {35, 14}, {43, 9} }, 1), leafR.shade)

-- twisted paper folds on the rim
for _, x in ipairs({ 17, 25, 33, 41, 48 }) do
  c:fill(c:line({ {x, 25}, {x + 2, 29} }, 1):clip(rim), tan.shade)
end
c:seam({ {14, 27}, {50, 27} })

-- paper fold lines on the cone
c:fill(c:line({ {22, 32}, {31, 52} }, 1):clip(cone:shrink(1)), paper.shade)
c:fill(c:line({ {41, 32}, {34, 50} }, 1):clip(cone:shrink(1)), paper.shade)

-- tie dots
for _, p in ipairs({ { 25, 37 }, { 31, 40 }, { 37, 37 } }) do
  c:paint({ "dd", "dd" }, p[1], p[2], { d = "#8c4a1a" })
end

local t = c:save(O .. "aseprite/ph/blood-lily-seed.aseprite", O .. "png/ph/blood-lily-seed.png")
print(GV.report(t))
