local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cloth = GV.ramp("#f4f0e0")
local leafR = GV.ramp("#58a03e")

-- round sack body with a pinched neck and two flaring cloth ears
local body = c:ellipse(31.5, 40, 19, 15)
local neck = c:poly({ { 24, 27 }, { 40, 27 }, { 36, 19 }, { 28, 19 } })
local tails = c:poly({ { 27, 20 }, { 31, 19 }, { 22, 11 }, { 18, 13 } })
tails:add(c:poly({ { 33, 19 }, { 37, 20 }, { 46, 13 }, { 42, 11 } }))
tails:add(c:rrect(26, 16, 37, 21, 2))
local string = c:rrect(23, 24, 40, 26, 1)
local loop = c:ellipse(43, 25, 3, 2.5):cut(c:ellipse(43, 25, 1, 0.5))
string:add(loop)
local ring = c:ellipse(31.5, 41, 9, 8):cut(c:ellipse(31.5, 41, 7, 6))
local win = c:ellipse(31.5, 41, 7, 6)
local seed = c:ellipse(31.5, 43, 5, 4.5)

c:build{
  { "tails", tails, GV.ramp("#f1ece0") },
  { "body", body, cloth, { stitch = { side = "lit" } } },
  { "neck", neck, cloth, { contour = false } },
  { "string", string, GV.ramp("#c9a96e"), { flat = true } },
  { "win", win, GV.ramp("#f4f0e0"), { flat = true, gloss = false } },
  { "ring", ring, GV.ramp("#b0bc66"), { flat = true } },
  { "seed", seed, GV.ramp("#b0bc66", { shade = "#58a03e" }) },
}
-- gather folds on the neck
c:px(29, 21, cloth.shade); c:px(29, 22, cloth.shade)
c:px(34, 21, cloth.shade); c:px(34, 22, cloth.shade)
-- stem and leaf
c:fill(c:rect(31, 36, 32, 38), "#2e5a2c")
c:paint({ ".ll.", "llll", ".ll." }, 33, 35, { l = "#58a03e" })
c:px(34, 35, leafR.rim)

c:seam({ { 23, 27 }, { 40, 27 } })

local t = c:save(O .. "aseprite/ph/sea-buckthorn-seed.aseprite", O .. "png/ph/sea-buckthorn-seed.png")
print(GV.report(t))
