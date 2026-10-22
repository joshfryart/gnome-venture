local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(32, 44, 18, 13.5)
mound:add(c:poly({ {32, 8}, {34, 12}, {41, 22}, {48, 36}, {16, 36}, {23, 22}, {30, 12} }))
mound:add(c:rect(31, 8, 32, 10))
local band = c:ellipse(32, 47, 15, 4):clip(mound)
local p = c:build{
  { "mound", mound, "moss", { gloss = { 23, 22 } } },
  { "band", band, GV.ramp("#4a8a3e"), { light = mound, gloss = false } },
}
c:fill(c:line({ {22, 32}, {26, 30} }, 2), "#2f5a2a")
c:fill(c:line({ {36, 37}, {40, 35} }, 2), "#2f5a2a")
c:fill(c:line({ {28, 24}, {31, 23} }, 2), "#2f5a2a")

c:ground(32, 58, 15, 1.5)
local t = c:save(O .. "aseprite/ph/dung-ball.aseprite", O .. "png/ph/dung-ball.png")
print(GV.report(t))
