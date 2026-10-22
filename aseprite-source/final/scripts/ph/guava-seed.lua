local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- twisted tip (behind the cone mouth, leaning right)
local tip = c:poly({ {40, 26}, {44, 18}, {46, 14}, {50, 8}, {54, 10}, {51, 16}, {50, 22}, {48, 27} })
tip:add(c:ellipse(50.5, 9.5, 3, 2.5))
-- cone body: wide mouth tapering to a narrow point
local cone = c:poly({ {12, 25}, {52, 25}, {36, 56}, {29, 56} })
cone:add(c:rrect(12, 23, 51, 29, 3))
-- guava peeking out of the mouth
local fruit = c:ellipse(30.5, 22, 11, 10):cut(c:rect(0, 27, 63, 63))
local stem = c:rect(30, 9, 32, 13)
local leaf = c:ellipse(37, 10.5, 4, 2.5)

local paper = GV.ramp("#f1ece0")
local p = c:build{
  { "tip",   tip,   GV.ramp("#dcb06a"), { gloss = false } },
  { "fruit", fruit, "gold" },
  { "stem",  stem,  GV.ramp("#2f5a2a"), { flat = true } },
  { "leaf",  leaf,  GV.ramp("#6a9a3a"), { gloss = false } },
  { "cone",  cone,  paper },
}
-- twist lines on the tip
c:paint({ "x..", ".x.", "..x" }, 46, 15, { x = "#b8862f" })
-- paper fold line
c:line({ {18, 31}, {33, 52} }, 2):clip(p.cone.m):each(function(x, y) c:px(x, y, "#dcb06a") end)
-- mouth rim seam
c:seam({ {15, 26}, {49, 26} })
c:ground(32.5, 57, 8, 1.5)
local t = c:save(O .. "aseprite/ph/guava-seed.aseprite", O .. "png/ph/guava-seed.png")
print(GV.report(t))
