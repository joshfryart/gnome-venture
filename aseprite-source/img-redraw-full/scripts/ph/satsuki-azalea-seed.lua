local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local cone = c:poly({ {13, 22}, {52, 22}, {33, 57}, {31, 57} })
cone:add(c:rrect(13, 20, 51, 26, 3))
local neck = c:poly({ {25, 21}, {39, 21}, {36, 14}, {28, 14} })
local knot = c:ellipse(32, 11, 4, 3.5)
local win = c:ellipse(32, 36, 9, 8)
local seed = c:ellipse(32, 37, 6, 6)
local leaf = c:ellipse(36.5, 30, 3, 1.5)

local p = c:build{
  { "knot", knot, "cream" },
  { "neck", neck, "cream" },
  { "cone", cone, "cream" },
  { "win", win, GV.ramp("#f4f0e0"), { gloss = false } },
  { "seed", seed, GV.ramp("#f08a24", { shade = "#e0501f" }) },
  { "leaf", leaf, GV.ramp("#58a03e"), { flat = true } },
}
-- spiral fold (outside the window)
c:fill(c:line({ {16, 25}, {45, 46} }, 2):cut(win:grow(1)):clip(cone:shrink(2)), "#dcb06a")
-- twist creases on the neck/knot
c:paint({ "f.f", ".f." }, 30, 16, { f = "#dcb06a" })
c:px(30, 10, "#dcb06a"); c:px(33, 12, "#dcb06a")
-- window rim
c:fill(win:copy():cut(win:shrink(1)), "#f08a24")
-- stem
c:fill(c:rect(31, 29, 32, 32), "#2e5a2c")
-- gold twist string around the neck
c:fill(c:rect(25, 19, 39, 20):clip(neck:grow(1)), "#f5cf6a")
c:px(39, 21, "#e8a317"); c:px(40, 22, "#e8a317")
c:seam({ {16, 23}, {49, 23} })

local t = c:save(O .. "aseprite/ph/satsuki-azalea-seed.aseprite", O .. "png/ph/satsuki-azalea-seed.png")
print(GV.report(t))
