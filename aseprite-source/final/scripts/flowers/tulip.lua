-- flowers/tulip : tulip bloom, three pointed tips over a round belly, no stem
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.R

local back = c:ellipse(31.5, 37, 18, 14)
back:add(c:poly({ {17, 12}, {13, 31}, {22, 38}, {31, 31} }))
back:add(c:poly({ {47, 12}, {51, 31}, {42, 38}, {33, 31} }))
local front = c:ellipse(31.5, 40, 9, 12)
front:add(c:poly({ {32, 11}, {37, 21}, {41, 36}, {23, 36}, {27, 21} }))

local backR = GV.ramp("#c4507f")
c:build{
  { "back",  back, backR, { gloss = { 19, 20 } } },
  { "front", front, "petal", { gloss = false } },
}
-- gloss streak down the lit side of the front petal, with a dot at its head
c:fill(c:line({ {29, 19}, {26, 28}, {26, 37}, {27, 43} }, 2), R.petal.rim)
c:paint({ "gg", "gg" }, 28, 16, { g = R.petal.gloss })
c:px(30, 20, R.petal.dot)
-- shade streak on the right
c:fill(c:line({ {36, 25}, {39, 32}, {37, 45} }, 2), R.petal.shade)
-- crease on the back petals below the notch is hidden; keep a short one at the belly
c:fill(c:line({ {32, 47}, {32, 49} }, 1), R.petal.shade)

local t = c:save(O .. "aseprite/flowers/tulip.aseprite", O .. "png/flowers/tulip.png")
print(GV.report(t))
