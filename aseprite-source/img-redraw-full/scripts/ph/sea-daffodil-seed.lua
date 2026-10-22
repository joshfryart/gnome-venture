local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local paper = GV.ramp("#f1ece0")
local flapR = GV.ramp("#dcb06a")
local leafR = GV.ramp("#58a03e")

-- wide flat packet with a dog-eared lower-right corner
local body = c:rrect(9, 15, 54, 52, 2):cut(c:poly({ { 55, 45 }, { 55, 53 }, { 47, 53 } }))
local flap = c:poly({ { 9, 15 }, { 55, 15 }, { 55, 25 }, { 32, 34 }, { 9, 25 } })
local ring = c:rrect(21, 31, 42, 50, 5):cut(c:rrect(23, 33, 40, 48, 4))
local win = c:rrect(23, 33, 40, 48, 4)
local seed = c:ellipse(31.5, 42, 6, 5.5)
local corner = c:poly({ { 47, 53 }, { 55, 45 }, { 47, 45 } })

c:build{
  { "body", body, paper },
  { "win", win, GV.ramp("#f4f0e0"), { flat = true, gloss = false } },
  { "ring", ring, GV.ramp("#3f93b2"), { flat = true } },
  { "seed", seed, GV.ramp("#3f93b2", { shade = "#256a80" }) },
  { "flap", flap, flapR },
  { "corner", corner, flapR, { flat = true } },
}
-- lit fold edge along the top of the flap
c:fill(c:rect(11, 16, 52, 16), paper.base)
-- stem and leaf poking out under the flap tip
c:fill(c:rect(31, 34, 32, 36), "#2e5a2c")
c:paint({ ".ll.", "llll", ".ll." }, 33, 34, { l = "#58a03e" })
c:px(34, 34, leafR.rim)

c:seam({ { 11, 26 }, { 30, 33 } })
c:seam({ { 33, 33 }, { 53, 26 } })
c:button(30, 30)

local t = c:save(O .. "aseprite/ph/sea-daffodil-seed.aseprite", O .. "png/ph/sea-daffodil-seed.png")
print(GV.report(t))
