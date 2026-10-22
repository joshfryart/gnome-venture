local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pouch body: round belly, wider than the neck
local body = c:ellipse(32, 40, 19, 14)
body:add(c:ellipse(32, 31, 12, 6))
-- ruffled neck: a fan of scallops above the drawstring
local ruffle = c:ellipse(32, 22, 10, 4)
ruffle:add(c:ellipse(24, 20, 3, 3)); ruffle:add(c:ellipse(29, 18, 3, 3))
ruffle:add(c:ellipse(35, 18, 3, 3)); ruffle:add(c:ellipse(40, 20, 3, 3))
ruffle:add(c:rect(23, 22, 41, 27))
-- drawstring band and two hanging tails
local cord = c:rect(21, 26, 43, 27)
cord:add(c:line({ {29, 27}, {25, 36} }, 2))
cord:add(c:line({ {35, 27}, {39, 36} }, 2))
local window = c:ellipse(32, 42, 8, 7)
local seed = c:ellipse(32, 43, 5, 5)

local p = c:build{
  { "body", body, GV.ramp("#f4f0e0"), { stitch = true } },
  { "ruffle", ruffle, GV.ramp("#f1ece0") },
  { "window", window, GV.ramp("#e9e2cc"), { gloss = false } },
  { "seed", seed, GV.ramp("#e46a9b", { shade = "#b8452f", deep = "#a8241f" }) },
  { "cord", cord, GV.ramp("#e46a9b"), { flat = true } },
}
-- tail tips
c:fill(c:rect(24, 36, 26, 38), "#f6b8cf")
c:fill(c:rect(38, 36, 40, 38), "#f6b8cf")
-- ruffle folds
c:px(26, 22, "#d9b88a"); c:px(26, 23, "#d9b88a")
c:px(32, 21, "#d9b88a"); c:px(32, 22, "#d9b88a")
c:px(38, 22, "#d9b88a"); c:px(38, 23, "#d9b88a")
-- stem and leaf on the seed
c:fill(c:rect(32, 36, 33, 38), "#2e5a2c")
c:paint({ ".ll.", "llll", ".ll." }, 34, 35, { l = "#58a03e" })
c:px(35, 35, "#8fcb6a")
c:seam({ {22, 28}, {42, 28} })
local t = c:save(O .. "aseprite/ph/sea-thrift-seed.aseprite", O .. "png/ph/sea-thrift-seed.png")
print(GV.report(t))
