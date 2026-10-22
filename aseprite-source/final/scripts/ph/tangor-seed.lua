local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- gathered cloth bundle: round sack, pinched neck, flared tuft
local tuft = c:ellipse(26.5, 15, 4.5, 4):add(c:ellipse(37.5, 15, 4.5, 4)):add(c:ellipse(32, 13, 3, 3.5))
local neck = c:poly({ {27, 17}, {37, 17}, {40, 30}, {24, 30} })
local body = c:ellipse(32, 41, 17, 14)
local fruit = c:ellipse(32, 43, 7, 7)
local leaf = c:ellipse(37.5, 35, 2.5, 2)

local p = c:build{
  { "tuft", tuft, GV.ramp("#f4f0e0") },
  { "neck", neck, "cream" },
  { "body", body, "cream", { stitch = { side = "lit" } } },
  { "fruit", fruit, GV.ramp("#f08a24") },
  { "leaf", leaf, "moss", { flat = true } },
}
-- string tie band, knot and two tails
local wood = GV.R.wood
local tie = c:rect(26, 23, 38, 25)
c:part(tie, "wood", { flat = true })
c:part(c:rrect(30, 22, 34, 26, 1), "wood", { flat = true })
c:line({ {30, 26}, {26, 31} }, 2)
c:fill(c:line({ {30, 26}, {26, 31} }, 2), wood.base)
c:fill(c:line({ {34, 26}, {38, 31} }, 2), wood.shade)
c:px(31, 23, wood.gloss)
c:seam({ {21, 49}, {43, 49} })
c:ground(32, 56, 15, 1.5)
local t = c:save(O .. "aseprite/ph/tangor-seed.aseprite", O .. "png/ph/tangor-seed.png")
print(GV.report(t))
