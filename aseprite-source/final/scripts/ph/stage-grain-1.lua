local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(32, 42.5, 20, 7.5)
local top = c:ellipse(31, 40, 15, 4.5)
c:build{
  { "mound", mound, GV.ramp("#8c4a1a") },
  { "top", top, GV.ramp("#a5663a"), { light = mound } },
}
local sprout = c:line({ {32, 40}, {32, 34}, {31, 30} }, 2)
sprout:add(c:poly({ {31, 32}, {26, 28}, {25, 31}, {29, 34} }))
sprout:add(c:poly({ {33, 35}, {38, 31}, {39, 34}, {35, 37} }))
c:part(sprout, GV.ramp("#58a03e"), { flat = true })
c:px(22, 41, "#7a4a1f"); c:px(38, 42, "#7a4a1f"); c:px(28, 43, "#7a4a1f")
c:ground(32, 50, 17, 1.5)
local t = c:save(O .. "aseprite/ph/stage-grain-1.aseprite", O .. "png/ph/stage-grain-1.png")
print(GV.report(t))
