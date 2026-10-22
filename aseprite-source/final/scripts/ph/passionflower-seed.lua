local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local burlap = GV.ramp("#b07a45")
local twine = GV.ramp("#8a4f2a")

local body = c:ellipse(32, 40, 17, 15)
local neck = c:poly({ {25,28}, {39,28}, {48,9}, {43,9}, {32,17}, {21,9}, {16,9} })
local p = c:build{
  { "body", body, burlap, { stitch = { side = "lit" } } },
  { "neck", neck, burlap, { light = body:copy():add(neck) } },
  { "twine", c:rrect(22, 24, 42, 26, 1), twine, { flat = true } },
  { "knot", c:rrect(29, 22, 34, 27, 1), twine, { gloss = false } },
  { "patch", c:ellipse(33, 42, 7, 7), "gold" },
}
-- weave hatch
c:paint({ "w.", ".w" }, 20, 36, { w = "#8a4f2a" })
c:paint({ "w.", ".w" }, 23, 47, { w = "#8a4f2a" })
c:paint({ "w.", ".w" }, 44, 46, { w = "#8a4f2a" })
c:paint({ "w.", ".w" }, 37, 12, { w = "#8a4f2a" })
-- fruit stem and leaf
c:fill(c:rect(33, 33, 34, 36), "#2e5a2c")
c:paint({ ".ll", "lll", "ll." }, 35, 32, { l = "#58a03e" })
c:px(36, 32, "#8fcf5a")
-- passionflower corona marks on the fruit
c:px(30, 43, "#b8661a"); c:px(36, 44, "#b8661a"); c:px(33, 46, "#b8661a")
c:seam({ {19, 31}, {17, 40}, {20, 50} })
c:ground(32, 55, 14, 1.5)
local t = c:save(O .. "aseprite/ph/passionflower-seed.aseprite", O .. "png/ph/passionflower-seed.png")
print(GV.report(t))
