local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local paper = GV.ramp("#f1ece0")
-- twisted tip: bowtie knot with a frilly top
local tip = c:poly({ {27,9}, {31,13}, {33,13}, {37,9}, {38,10}, {35,17}, {29,17}, {26,10} })
-- cone body: narrows upward from a wide bottom
local cone = c:poly({ {28,17}, {36,17}, {50,54}, {48,56}, {16,56}, {14,54} })

local p = c:build{
  { "tip",  tip,  paper },
  { "cone", cone, paper, { light = cone } },
}
-- crease on the twist
c:fill(c:line({ {29,11}, {32,15}, {35,11} }, 1), "#dcb06a")
-- fold lines
c:fill(c:line({ {29,19}, {21,53} }, 1), "#dcb06a")
c:fill(c:line({ {35,19}, {43,53} }, 1), "#dcb06a")
-- window
local win = c:ellipse(32, 39, 9, 8)
c:fill(win:copy():grow(1):cut(win), "#dcb06a")
c:fill(win, "#fbf6e8")
-- seed
local seed = c:ellipse(32, 41, 5, 4)
c:fill(seed, "#dcb06a")
c:fill(c:ellipse(33, 42, 4, 3):cut(c:ellipse(31, 40, 4, 3)), "#a5663a")
c:px(30, 39, "#fff3c8"); c:px(31, 39, "#fff3c8")
-- sprout
c:fill(c:rect(32, 33, 33, 37), "#2f5a2a")
c:fill(c:ellipse(35.5, 33, 2, 1.5), "#58a03e")
c:px(35, 32, "#c8d77a")
-- label dots
for _, x in ipairs({ 26, 32, 38 }) do c:fill(c:rect(x - 1, 51, x, 52), "#8c4a1a") end
-- seam where the twist meets the cone
c:seam({ {27, 18}, {37, 18} }, { free = true })

local t = c:save(O .. "aseprite/ph/cape-daisy-seed.aseprite", O .. "png/ph/cape-daisy-seed.png")
print(GV.report(t))
