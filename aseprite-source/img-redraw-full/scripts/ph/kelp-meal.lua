local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local sack = c:rrect(10, 18, 54, 56, 6):add(c:rect(12, 16, 52, 24))
local flap = c:poly({ {17, 10}, {47, 10}, {50, 22}, {14, 22} })
local p = c:build{
  { "sack", sack, GV.ramp("#a5663a"), { stitch = { side = "lit" } } },
  { "flap", flap, GV.ramp("#dcb06a") },
  { "badge", c:ellipse(32, 38, 12, 10), GV.ramp("#58a03e") },
}
-- kelp frond V with a stem
c:fill(c:line({ {25, 33}, {32, 42}, {39, 33} }, 2), "#2e5a2c")
c:fill(c:line({ {32, 42}, {32, 45} }, 2), "#2e5a2c")
c:fill(c:line({ {28, 37}, {26, 38} }, 1), "#2e5a2c")
c:fill(c:line({ {36, 37}, {38, 38} }, 1), "#2e5a2c")
-- fold creases
c:fill(c:line({ {16, 27}, {19, 30} }, 1), "#5e2f1e")
c:fill(c:line({ {47, 28}, {49, 32} }, 1), "#5e2f1e")
c:fill(c:line({ {17, 49}, {21, 52} }, 1), "#5e2f1e")
c:seam({ {16, 21}, {48, 21} })
c:button(30, 13)
c:ground(32, 57, 20, 1.5)
local t = c:save(O .. "aseprite/ph/kelp-meal.aseprite", O .. "png/ph/kelp-meal.png")
print(GV.report(t))
