local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local ember = GV.ramp("#e0501f")
local orange = GV.ramp("#f08a24")
local cream = GV.ramp("#f8eed2")

-- bushy tail curling up on the right
local tail = c:ellipse(48, 46, 7, 10)
tail:add(c:ellipse(50, 37, 6, 7))
local tip = c:ellipse(51, 33, 4.5, 5):clip(tail)

local p = c:build{
  { "tail",  tail, ember },
  { "tip",   tip,  cream, { gloss = false, contact = false } },
  { "pawL",  c:ellipse(22, 53, 6.5, 3.5), ember },
  { "pawR",  c:ellipse(41, 53, 6.5, 3.5), ember },
  { "body",  c:ellipse(31.5, 43, 15, 13), orange, { light = c:ellipse(31.5, 38, 20, 22) } },
  { "chest", c:ellipse(31.5, 46, 8, 8), cream, { gloss = false, contour = false } },
  { "earL",  c:poly({ {17, 23}, {16, 7}, {29, 15} }), orange },
  { "earR",  c:poly({ {35, 15}, {47, 7}, {47, 23} }), orange },
  { "head",  c:ellipse(31.5, 26, 13, 12), orange },
}
-- inner ears
c:fill(c:poly({ {19, 17}, {19, 10}, {24, 15} }), "#c03a1a")
c:fill(c:poly({ {40, 15}, {45, 10}, {45, 17} }), "#c03a1a")
-- muzzle
c:part(c:ellipse(31.5, 32, 6, 5), cream, { gloss = false })
-- nose
c:paint({ ".nn.", "nnnn", ".nn." }, 30, 28, { n = "#2a1a10" })
c:px(30, 28, "#5e2a3a")
-- mouth
c:paint({ "m..m", ".mm." }, 30, 33, { m = "#4a2c1a" })
-- eyes
c:eye(22, 21); c:eye(37, 21)

local t = c:save(O .. "aseprite/ico/ico-fox.aseprite", O .. "png/ico/ico-fox.png")
print(GV.report(t))
