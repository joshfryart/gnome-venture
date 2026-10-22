local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- slumped pouch bulb: wide bottom, narrower shoulders
local body = c:ellipse(32, 42, 18, 14)
body:add(c:rrect(14, 40, 50, 56, 9))
body:add(c:ellipse(32, 30, 12, 8))
-- gathered neck (trapezoid)
local neck = c:poly({ {23, 14}, {42, 14}, {39, 25}, {26, 25} })
-- ruffled frill: wavy top
local frill = c:ellipse(32, 13, 13, 4)
frill:add(c:ellipse(22, 11, 3, 3)); frill:add(c:ellipse(28, 10, 3, 3))
frill:add(c:ellipse(35, 10, 3, 3)); frill:add(c:ellipse(41, 11, 3, 3))

local p = c:build{
  { "body",  body,  "#f1ece0", { stitch = { side = "lit" } } },
  { "neck",  neck,  "#e6d9b8" },
  { "frill", frill, "#f1ece0" },
}
-- neck folds
c:fill(c:line({ {29, 16}, {29, 23} }, 1), "#c9a96e")
c:fill(c:line({ {35, 16}, {35, 23} }, 1), "#c9a96e")
c:seam({ {32, 15}, {32, 23} })

-- drawstring around neck + dangling ends
local th = GV.ramp("#dcb06a")
c:part(c:line({ {22, 22}, {43, 22} }, 2), th, { flat = true })
c:part(c:line({ {23, 23}, {20, 27}, {18, 31} }, 2), th, { flat = true })
c:part(c:line({ {42, 23}, {45, 27}, {46, 31} }, 2), th, { flat = true })
c:paint({ "aa", "aa" }, 17, 31, { a = th.shade })
c:paint({ "aa", "aa" }, 45, 31, { a = th.shade })
-- knot
c:part(c:rrect(30, 20, 34, 24, 1), th, { gloss = false })

-- label patch with pink ring
local lab = c:rrect(20, 29, 44, 52, 6)
c:part(lab, "#f4f0e0", { gloss = false })
local ring = lab:copy():cut(lab:shrink(2))
c:fill(ring, "#e46a9b")

-- copihue berry (bell-berry)
local berry = c:ellipse(32, 42, 7, 7)
c:part(berry, GV.ramp("#e46a9b", { shade = "#c23a5a", deep = "#a8241f" }))
-- stem + leaf
c:fill(c:line({ {32, 33}, {32, 35} }, 2), "#2e5a2c")
local leaf = c:poly({ {33, 34}, {36, 30}, {40, 29}, {39, 32}, {35, 35} })
c:part(leaf, GV.ramp("#58a03e"), { flat = true })
c:px(36, 32, "#2e5a2c"); c:px(37, 31, "#2e5a2c")

local t = c:save(O .. "aseprite/ph/copihue-seed.aseprite", O .. "png/ph/copihue-seed.png")
print(GV.report(t))
