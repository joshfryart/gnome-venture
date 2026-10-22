local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- sack body: narrow shoulders, bulging round bottom
local body = c:ellipse(32, 41, 19, 14)
body:add(c:poly({ {22, 20}, {42, 20}, {50, 34}, {14, 34} }))
-- gathered tuft with ruffle peaks above the cinch
local tuft = c:poly({ {19, 21}, {17, 13}, {22, 15}, {26, 9}, {30, 13}, {34, 8}, {38, 13}, {43, 9}, {46, 15}, {47, 21} })
local cord = c:rrect(18, 19, 46, 22, 1)
local patch = c:rrect(21, 27, 43, 50, 5)

local p = c:build{
  { "tuft", tuft, "cream", { cres = 3 } },
  { "body", body, "cream" },
  { "cord", cord, GV.ramp("#dcb06a"), { flat = true } },
  { "patch", patch, GV.ramp("#f4f0e0"), { gloss = false } },
}
-- moss rim around patch
c:fill(patch:copy():cut(patch:shrink(1)), "#a4b86a")
-- tuft fold lines
c:paint({ "s", "s", "s" }, 26, 13, { s = "#dcb06a" })
c:paint({ "s", "s", "s" }, 34, 12, { s = "#dcb06a" })
c:paint({ "s", "s", "s" }, 41, 13, { s = "#dcb06a" })
-- bow tails
local tails = c:line({ {38, 22}, {37, 28} }, 2):add(c:line({ {43, 22}, {46, 28} }, 2))
c:fill(tails, "#c49a4e")
c:fill(c:rect(37, 27, 38, 28), "#dcb06a"); c:fill(c:rect(45, 27, 46, 28), "#dcb06a")
c:px(38, 22, "#f1d898"); c:px(43, 22, "#f1d898")
-- bamboo shoot emblem: diagonal pill
local shoot = c:line({ {27, 43}, {37, 30} }, 6)
local lower = shoot:copy():clip(c:poly({ {20, 34}, {44, 50}, {20, 50} }))
c:fill(shoot, "#b0bc66")
c:fill(lower, "#58a03e")
c:fill(shoot:copy():clip(c:poly({ {33, 26}, {44, 26}, {44, 34} })), "#2e5a2c")
-- shoot sheath bands
c:fill(c:line({ {28, 37}, {33, 41} }, 1):clip(shoot), "#2e5a2c")
c:fill(c:line({ {31, 33}, {36, 37} }, 1):clip(shoot), "#7e9a3a")
c:px(30, 36, "#e6eeb0"); c:px(31, 35, "#e6eeb0")
-- stitch ring inside patch
c:stitch(patch)
-- three stitch dots at bottom
for _, x in ipairs({ 26, 32, 38 }) do c:fill(c:rect(x, 52, x + 1, 53), "#8c4a1a") end
c:ground(32, 57, 17, 2)
local t = c:save(O .. "aseprite/ph/bamboo-shoot-seed.aseprite", O .. "png/ph/bamboo-shoot-seed.png")
print(GV.report(t))
