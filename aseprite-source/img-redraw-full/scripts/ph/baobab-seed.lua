local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glass = GV.ramp("#d8ece4")
local jar  = c:rrect(15, 19, 48, 53, 6)
local neck = c:rrect(19, 14, 44, 20, 2)
local cork = c:poly({ {22, 6}, {42, 6}, {40, 15}, {24, 15} })
local seed = c:ellipse(31.5, 41, 8, 7.5)

local p = c:build{
  { "jar",  jar,  glass, { gloss = false } },
  { "neck", neck, glass, { gloss = false } },
  { "cork", cork, "wood" },
  { "seed", seed, GV.ramp("#dcb06a") },
}
-- glass gloss strip down the upper-left
c:fill(c:rect(18, 24, 19, 40), "#fff1c8"); c:fill(c:rect(18, 43, 19, 44), "#fff1c8")
c:px(22, 23, "#ffffff")
-- cork dark band and grain
c:fill(c:rect(24, 11, 40, 11), "#8a4f2a")
c:px(27, 8, "#8a4f2a"); c:px(35, 9, "#8a4f2a"); c:px(31, 13, "#8a4f2a")
-- twine round the cork neck
c:seam({ {20, 16}, {43, 16} }, { free = true })
-- sprout from top of seed
c:fill(c:rect(31, 28, 32, 34), "#2f5a2a")
c:paint({ "..lll", ".llll", "llll.", "ll..." }, 33, 25, { l = "#7ab55c" })
c:paint({ "ll.", "lll", ".ll" }, 27, 28, { l = "#4a8a3e" })
c:px(35, 25, "#c8d77a")
-- seed pattern dots
c:px(29, 40, "#a5663a"); c:px(34, 43, "#a5663a"); c:px(30, 45, "#a5663a")
-- base dots
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 50, x + 1, 51), "#8c4a1a") end
c:ground(31.5, 56, 16, 1.5)
local t = c:save(O .. "aseprite/ph/baobab-seed.aseprite", O .. "png/ph/baobab-seed.png")
print(GV.report(t))
