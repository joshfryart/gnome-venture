local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local plinth = c:poly({ {21,39}, {43,39}, {48,55}, {16,55} })
plinth:add(c:rrect(18, 38, 45, 42, 1))
local ball = c:ellipse(31.5, 25, 14)
local p = c:build{
  { "plinth", plinth, "stone" },
  { "ball", ball, "water", { gloss = { 24, 17 } } },
}
c:fill(c:line({ {22,29}, {25,28}, {28,29}, {31,30}, {34,29}, {37,28} }, 1), "#c8ecdc")
c:fill(c:line({ {27,34}, {30,33}, {33,34}, {36,33} }, 1), "#8fcbd8")
c:seam({ {19,44}, {44,44} })
c:ground(31.5, 55, 17, 1.5)
local t = c:save(O .. "aseprite/ph/gazing-ball.aseprite", O .. "png/ph/gazing-ball.png")
print(GV.report(t))
