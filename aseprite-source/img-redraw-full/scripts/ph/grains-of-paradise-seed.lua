local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- slumped fat pouch: wider at the bottom
local body = c:ellipse(31.5, 40, 20, 16)
body:add(c:ellipse(31.5, 32, 14, 10))
local neck = c:poly({ {25, 15}, {39, 15}, {38, 26}, {26, 26} })
local ruffle = c:poly({ {20, 10}, {44, 10}, {41, 17}, {23, 17} })
local band = c:rrect(23, 21, 40, 24, 1)
local patch = c:rrect(22, 33, 41, 49, 4)

local p = c:build{
  { "body", body, "cream", { stitch = true } },
  { "neck", neck, GV.ramp("#e6dcc4"), { gloss = false } },
  { "ruffle", ruffle, "cream", { gloss = { 25, 12 } } },
  { "band", band, GV.ramp("#e0501f"), { flat = true } },
  { "patch", patch, GV.ramp("#f08a24"), { gloss = false } },
  { "patchin", c:rrect(24, 35, 39, 47, 3), GV.ramp("#f4f0e0"), { gloss = false, contour = false, contact = false } },
}
-- cord tails dangling from the knot
c:part(c:line({ {37, 24}, {40, 31} }, 2), GV.ramp("#e0501f"), { flat = true })
c:part(c:line({ {34, 24}, {34, 30} }, 2), GV.ramp("#e0501f"), { flat = true })
c:fill(c:rect(39, 31, 41, 32), "#b8452f")
c:fill(c:rect(33, 30, 35, 31), "#b8452f")

-- neck folds
c:fill(c:line({ {29, 17}, {29, 20} }, 1), "#c9a96e")
c:fill(c:line({ {34, 17}, {35, 20} }, 1), "#c9a96e")
-- ruffle pleats
c:paint({ "k...k...k...k" }, 26, 15, { k = "#c9a96e" })

-- grains of paradise pod
local pod = c:poly({ {27, 38}, {34, 36}, {39, 38}, {39, 42}, {35, 45}, {28, 45}, {26, 42} })
c:part(pod, GV.ramp("#f08a24"), { gloss = { 29, 39 }, contact = false })
c:paint({
  "s.s.s",
  "s.s.s",
}, 30, 39, { s = "#6b1b2c" })
c:fill(c:line({ {25, 39}, {27, 41} }, 2), "#2f5a2a")
-- seam round the patch border
c:seam({ {23, 34}, {40, 34}, {40, 48}, {23, 48}, {23, 34} }, { free = true })

local t = c:save(O .. "aseprite/ph/grains-of-paradise-seed.aseprite", O .. "png/ph/grains-of-paradise-seed.png")
print(GV.report(t))
